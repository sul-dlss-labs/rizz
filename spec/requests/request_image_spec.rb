# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request image' do
  let(:file_cache) { instance_double(FileCache, find: nil, write: nil) }

  before do
    allow(ImageService).to receive(:call).and_return(ImageResponse.new(buffer: 'image', mime_type: 'image/jpeg'))
    allow(FileCache).to receive(:new).and_return(file_cache)
  end

  context 'when the request is valid' do
    it 'returns the image' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('image')
      expect(response.content_type).to eq('image/jpeg')
      expect(response.headers['Cache-Control']).to eq('max-age=86400, public')

      expected_image_request = ImageRequest.new(identifier: 'bc151bq1744_00_0001.jp2', region: 'full', size: '400,400',
                                                rotation: '0', quality: 'default', format: 'jpg')
      expect(ImageService).to have_received(:call) do |image_request:, filepath:|
        expect(image_request.to_json).to match(expected_image_request.to_json)
        expect(filepath).to eq('images/bc151bq1744_00_0001.jp2')
      end

      expect(file_cache).to have_received(:find).with(request: ActionDispatch::Request,
                                                      updated_at: File.mtime('images/bc151bq1744_00_0001.jp2'))
      expect(file_cache).to have_received(:write).with(request: ActionDispatch::Request, body: 'image')
    end
  end

  context 'when the request has an extension' do
    it 'sets the format to the extension' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default.png'

      expect(response).to have_http_status(:ok)

      expect(ImageService).to have_received(:call) do |image_request:, filepath:| # rubocop:disable Lint/UnusedBlockArgument
        expect(image_request.format).to eq('png')
      end
    end
  end

  context 'when the identifier has a colon' do
    before do
      allow(FileResolvers::BasicFilename).to receive(:resolve)
        .and_return('images/bc151bq1744_00_0001.jp2')
    end

    it 'allows the colon' do
      get '/image-server/bc151bq1744:00_0001.jp2/full/400,400/0/default.png'

      expect(response).to have_http_status(:ok)

      expect(ImageService).to have_received(:call) do |image_request:, filepath:| # rubocop:disable Lint/UnusedBlockArgument
        expect(image_request.identifier).to eq('bc151bq1744:00_0001.jp2')
      end
    end
  end

  context 'when the image is missing' do
    it 'returns a 404' do
      get '/image-server/xbc151bq1744_00_0001.jp2/full/400,400/0/default'

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when public caching is disabled' do
    before do
      allow(Settings).to receive(:public_cache).and_return(false)
    end

    it 'sets the cache control header to prevent caching' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('image')
      expect(response.content_type).to eq('image/jpeg')
      expect(response.headers['Cache-Control']).to eq('max-age=0, private, must-revalidate')
    end
  end

  context 'when a cache hit' do
    before do
      allow(file_cache).to receive(:find).and_return('spec/fixtures/fake_image.jp2')
    end

    it 'returns the image from cache' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("fake image\n")
      expect(response.content_type).to eq('image/jpeg')
      expect(response.headers['Cache-Control']).to eq('max-age=86400, public')

      expect(ImageService).not_to have_received(:call)

      expect(file_cache).to have_received(:find).with(request: ActionDispatch::Request,
                                                      updated_at: File.mtime('images/bc151bq1744_00_0001.jp2'))
      expect(file_cache).not_to have_received(:write)
    end
  end
end
