# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request image' do
  let(:file_cache) { instance_double(FileCache, find: nil, write: nil) }

  let(:expected_info) do
    {
      foo: 1
    }.with_indifferent_access
  end

  before do
    allow(FileCache).to receive(:new).and_return(file_cache)
  end

  context 'when the request is valid' do
    before do
      allow(InfoBuilder).to receive(:call).and_return(expected_info)
    end

    it 'returns the info' do
      get '/image-server/bc151bq1744_00_0001.jp2/info.json'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to match(expected_info) # rubocop:disable Rails/ResponseParsedBody
      expect(response.content_type).to eq('application/ld+json; profile="http://iiif.io/api/image/3/context.json"; ' \
                                          'charset=utf-8')
      expect(response.headers['Cache-Control']).to eq('max-age=86400, public')

      expect(InfoBuilder).to have_received(:call).with(filepath: 'images/bc151bq1744_00_0001.jp2', id: 'http://www.example.com/image-server/bc151bq1744_00_0001.jp2')
      expect(file_cache).to have_received(:find).with(request: ActionDispatch::Request,
                                                      updated_at: File.mtime('images/bc151bq1744_00_0001.jp2'))
      expect(file_cache).to have_received(:write).with(request: ActionDispatch::Request, body: expected_info.to_json)
    end
  end

  context 'when the image is missing' do
    it 'returns a 404' do
      get '/image-server/xbc151bq1744_00_0001.jp2/info.json'

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when a cache hit' do
    before do
      allow(file_cache).to receive(:find).and_return('spec/fixtures/info.json')
      allow(InfoBuilder).to receive(:call)
    end

    it 'returns the image from cache' do
      get '/image-server/bc151bq1744_00_0001.jp2/info.json'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(File.read('spec/fixtures/info.json'))
      expect(response.content_type).to eq('application/ld+json; profile="http://iiif.io/api/image/3/context.json"; ' \
                                          'charset=utf-8')
      expect(response.headers['Cache-Control']).to eq('max-age=86400, public')

      expect(InfoBuilder).not_to have_received(:call)

      expect(file_cache).to have_received(:find).with(request: ActionDispatch::Request,
                                                      updated_at: File.mtime('images/bc151bq1744_00_0001.jp2'))
      expect(file_cache).not_to have_received(:write)
    end
  end

  context 'when info.json is omitted' do
    it 'redirects' do
      get '/image-server/bc151bq1744_00_0001.jp2'

      expect(response).to have_http_status(:redirect)
      expect(response.headers['location']).to eq('http://www.example.com/image-server/bc151bq1744_00_0001.jp2/info.json')
    end
  end
end
