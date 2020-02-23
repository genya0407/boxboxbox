# frozen_string_literal: true

require 'zip'

module Boxboxbox
  class Unzipper
    def initialize(target_extensions:)
      @target_extensions = target_extensions
    end

    def unzip(zip_path:)
      Enumerator.new do |yielder|
        Zip::InputStream.open(zip_path) do |zis|
          while entry = zis.get_next_entry
            next unless entry.name =~ target_extensions_regexp

            yielder << Image.new(name: entry.name, binary: entry.get_input_stream.read)
          end
        end
        nil
      end
    end

    private

    def target_extensions_regexp
      @target_extensions_regexp ||= Regexp.new(%w[png jpg jpeg].map { |ext| ".#{ext}$" }.join('|'))
    end
  end
end
