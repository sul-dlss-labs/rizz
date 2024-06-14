# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request image' do
  let(:file_cache) { instance_double(FileCache, find: nil, write: nil) }

  context 'when the request is valid' do
    let(:expected_info) do
      {
        foo: 1
      }.with_indifferent_access
    end

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

      expect(InfoBuilder).to have_received(:call).with(filepath: 'images/bc151bq1744_00_0001.jp2', id: 'http://www.example.com/image-server/bc151bq1744_00_0001.jp2/info')
    end
  end

  context 'when the image is missing' do
    it 'returns a 404' do
      get '/image-server/xbc151bq1744_00_0001.jp2/info.json'

      expect(response).to have_http_status(:not_found)
    end
  end
end
