require 'zip'

module Boxboxbox
  class Unzipper
    TARGET_EXTENSION_REGEX = Regexp.new(%w(png jpg jpeg).map { |ext| ".#{ext}$" }.join('|'))

    def unzip(zip_path:)
      Enumerator.new do |yielder|
        Zip::File.open(zip_path) do |zip_file|
          zip_file.each do |entry|
            next unless entry.name =~ TARGET_EXTENSION_REGEX
            entry.extract
            yielder << Image.new(name: entry.name, binary: entry.get_input_stream.read)
          end
        end
        nil
      end
    end
  end
end
