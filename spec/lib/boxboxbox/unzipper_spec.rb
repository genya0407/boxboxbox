# frozen_string_literal: true

require 'spec_helper'

describe Boxboxbox::Unzipper do
  describe '.unzip' do
    context 'jpg, pngをターゲットに初期化したインスタンスにzipのPathnameが渡されたとき' do
      let(:unzipper) { Boxboxbox::Unzipper.new(target_extensions: %w[jpg png]) }
      let(:zip_path) do
        require 'tmpdir'
        require 'securerandom'

        Pathname(Dir.tmpdir).join(SecureRandom.hex)
      end

      before do
        require 'zip_file_generator'

        zip_source_dir = File.join(SPEC_FIXTURE_DIR, 'sample_zip') # see spec/fixtures
        ZipFileGenerator.new(zip_source_dir, zip_path).write
      end

      after do
        File.delete(zip_path)
      end

      it 'jpg, pngのimageを取得する' do
        expect(unzipper.unzip(zip_path: zip_path).to_a.size).to eq 2
      end

      it 'nameがファイル名になる' do
        expect(unzipper.unzip(zip_path: zip_path).map(&:name)).to contain_exactly('child/hohho.png', 'hoge.jpg')
      end
    end
  end
end
