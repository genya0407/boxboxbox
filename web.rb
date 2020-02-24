# frozen_string_literal: true

$LOAD_PATH.push(File.join(__FILE__, '../lib'))

require 'sinatra'
require 'boxboxbox'
require 'toml-rb'
require 'time'

Config = Struct.new(:username, :password, :localizer_batch_size, :max_results, :min_percentage, :max_retry, :target_extensions, keyword_init: true) do
  def self.parse(config_string)
    toml = TomlRB.parse(config_string)
    web = toml['web']
    new(
      username: web.fetch('username'),
      password: web.fetch('password'),
      localizer_batch_size: web.fetch('localizer_batch_size'),
      max_results: web.fetch('max_results'),
      min_percentage: web.fetch('min_percentage'),
      max_retry: web.fetch('max_retry'),
      target_extensions: web.fetch('target_extensions')
    )
  end
end

config_path = ARGV[0]
config = Config.parse(File.read(config_path))
logger = Logger.new(STDERR)

use Rack::Auth::Basic, 'Secret area' do |username, password|
  username == config.username && password == config.password
end

get '/' do
  haml :index
end

post '/convert' do
  zip_file = params.dig('image_zip', 'tempfile')
  unless zip_file
    logger.warn('image_zip invalid')
    halt 422
    next
  end
  access_token = params.dig('access_token').to_s
  unless access_token
    logger.warn('access_token invalid')
    halt 422
    next
  end

  unzipper = Boxboxbox::Unzipper.new(target_extensions: config.target_extensions)
  localizer = Boxboxbox::BoxLocalizer::GoogleVisionApiOnline.new(
    access_token: access_token,
    max_results: config.max_results,
    min_percentage: config.min_percentage,
    max_retry: config.max_retry
  )

  boxes = []
  unzipper.unzip(zip_path: Pathname(zip_file.path)).each_slice(config.localizer_batch_size) do |batch_images|
    batch_boxes = localizer.localize(images: batch_images)
    boxes.concat(batch_boxes)
  end

  csv_string = Boxboxbox::BoxPresenter::Csv.new.present(boxes: boxes)
  Tempfile.open do |fp|
    fp.write csv_string
    fp.flush
    send_file fp.path, type: :csv, filename: "#{Time.now.iso8601.gsub(/[^0-9]/, '')}.csv"
  end
end
