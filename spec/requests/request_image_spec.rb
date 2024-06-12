# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request image' do
  before do
    allow(ImageService).to receive(:call).and_return(ImageResponse.new(buffer: 'image', mime_type: 'image/jpeg'))
  end

  context 'when the request is valid' do
    it 'returns the image' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default'

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('image')
      expect(response.content_type).to eq('image/jpeg')

      expected_image_request = ImageRequest.new(identifier: 'bc151bq1744_00_0001.jp2', region: 'full', size: '400,400',
                                                rotation: '0', quality: 'default', format: 'jpg')
      expect(ImageService).to have_received(:call) do |image_request:, vips_source:|
        expect(image_request.to_json).to match(expected_image_request.to_json)
        expect(vips_source).to be_an_instance_of(Vips::Source)
      end
    end
  end

  context 'when the request has an extension' do
    it 'sets the format to the extension' do
      get '/image-server/bc151bq1744_00_0001.jp2/full/400,400/0/default.png'

      expect(response).to have_http_status(:ok)

      expect(ImageService).to have_received(:call) do |image_request:, vips_source:| # rubocop:disable Lint/UnusedBlockArgument
        expect(image_request.format).to eq('png')
      end
    end
  end

  context 'when the identifier has a colon' do
    before do
      allow(VipsSourceResolvers::BasicFilename).to receive(:resolve)
        .and_return(Vips::Source.new_from_file('images/bc151bq1744_00_0001.jp2'))
    end

    it 'allows the colon' do
      get '/image-server/bc151bq1744:00_0001.jp2/full/400,400/0/default.png'

      expect(response).to have_http_status(:ok)

      expect(ImageService).to have_received(:call) do |image_request:, vips_source:| # rubocop:disable Lint/UnusedBlockArgument
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
end
