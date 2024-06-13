# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileCache do
  let(:file_cache) { described_class.new(cache_path:) }
  let(:cache_path) { 'tmp/test-cache' }

  let(:request) do
    instance_double(ActionDispatch::Request, path: '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default',
                                             format: 'image/jpeg')
  end

  let(:expected_cache_filepath) { "#{File.join(cache_path, request.path)}.jpg" }

  before do
    FileUtils.rm_rf(cache_path)
  end

  describe '.find' do
    let(:cache_filepath) { file_cache.find(request:, updated_at:) }

    let(:updated_at) { nil }

    context 'when cache file does not exist' do
      it 'returns nil' do
        expect(cache_filepath).to be_nil
      end
    end

    context 'when cache file exists' do
      before do
        FileUtils.mkdir_p(File.dirname(expected_cache_filepath))
        File.write(expected_cache_filepath, 'test')
      end

      it 'returns the cache file path' do
        expect(cache_filepath).to eq(expected_cache_filepath)
      end
    end

    context 'when cache file exists but is stale' do
      let(:updated_at) { File.mtime(expected_cache_filepath) + 1.hour }

      before do
        FileUtils.mkdir_p(File.dirname(expected_cache_filepath))
        File.write(expected_cache_filepath, 'test')
      end

      it 'returns nil and deletes the cache file' do
        expect(cache_filepath).to be_nil
        expect(File.exist?(expected_cache_filepath)).to be false
      end
    end

    context 'when cache file exists and is fresh' do
      let(:updated_at) { File.mtime(expected_cache_filepath) - 1.hour }

      before do
        FileUtils.mkdir_p(File.dirname(expected_cache_filepath))
        File.write(expected_cache_filepath, 'test')
      end

      it 'returns the cache file path and touches the cache file' do
        original_mtime = File.mtime(expected_cache_filepath)
        expect(cache_filepath).to eq(expected_cache_filepath)
        expect(File.mtime(expected_cache_filepath)).to be > original_mtime
      end
    end

    context 'when file cache is not enabled' do
      before do
        FileUtils.mkdir_p(File.dirname(expected_cache_filepath))
        File.write(expected_cache_filepath, 'test')
        allow(Settings.file_cache).to receive(:enabled).and_return(false)
      end

      it 'returns nil' do
        expect(cache_filepath).to be_nil
      end
    end
  end

  describe '.write' do
    let(:body) { 'test' }

    it 'writes the body to the cache' do
      file_cache.write(request:, body:)

      expect(File.exist?(expected_cache_filepath)).to be true
      expect(File.read(expected_cache_filepath)).to eq(body)
    end

    context 'when file cache is not enabled' do
      before do
        allow(Settings.file_cache).to receive(:enabled).and_return(false)
      end

      it 'does not write to the cache' do
        file_cache.write(request:, body:)

        expect(File.exist?(expected_cache_filepath)).to be false
      end
    end
  end
end
