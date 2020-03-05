# frozen_string_literal: true

require 'zip'

module Boxboxbox
  class Unzipper
    MACOS_METADATA_PATTERNS = %r{__MACOSX/|.DS_Store}.freeze

    def initialize(target_extensions:, ignore_regexp: MACOS_METADATA_PATTERNS)
      @target_extensions = target_extensions
      @ignore_regexp = ignore_regexp
    end

    def unzip(zip_path:)
      Enumerator.new do |yielder|
        Zip::File.open(zip_path) do |zip_file|
          zip_file.each do |entry|
            next if entry.name =~ @ignore_regexp
            next unless entry.name =~ target_extensions_regexp

            yielder << BinaryImage.new(name: entry.name, binary: entry.get_input_stream.read)
          end
        end
        nil
      end
    end

    private

    def target_extensions_regexp
      @target_extensions_regexp ||= Regexp.new(@target_extensions.map { |ext| ".#{ext}$" }.join('|'))
    end
  end
end
