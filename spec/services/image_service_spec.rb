# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImageService do
  let(:image_request) do
    ImageRequest.new(identifier: 'bc151bq1744_00_0001.jp2', region: 'full', size: '400,400', rotation: '0',
                     quality: 'default', format: 'jpg')
  end
  let(:vips_source) { Vips::Source.new_from_file('images/bc151bq1744_00_0001.jp2') }

  describe '.pipeline' do
    subject(:pipeline) { described_class.new(image_request:, vips_source:).pipeline }

    it 'returns a pipeline' do
      expect(pipeline).to be_an_instance_of(ImageProcessing::Builder)
      expect(pipeline.options[:operations]).to eq([[:resize_to_fit, [400, 400, { size: :force }]]])
    end
  end

  describe '.call' do
    subject(:image_response) { described_class.call(image_request:, vips_source:) }
    let(:pipeline) { instance_double(ImageProcessing::Builder, call: vips_image) }
    let(:vips_image) { instance_double(Vips::Image, write_to_buffer: 'image') }

    before do
      allow(ImageProcessing::Vips).to receive(:source).and_return(pipeline)
      allow(ImageServiceOperations::Crop).to receive(:call).and_return(pipeline)
      allow(ImageServiceOperations::Resize).to receive(:call).and_return(pipeline)
      allow(ImageServiceOperations::Rotation).to receive(:call).and_return(pipeline)
      allow(ImageServiceOperations::Colorspace).to receive(:call).and_return(pipeline)
    end

    it 'returns an image response' do
      expect(image_response).to be_an_instance_of(ImageResponse)
      expect(image_response.buffer).to eq('image')
      expect(image_response.mime_type).to eq('image/jpeg')

      expect(ImageProcessing::Vips).to have_received(:source).with(Vips::Image)
      expect(ImageServiceOperations::Crop).to have_received(:call)
        .with(pipeline:,
              region: image_request.region, image: Vips::Image)
      expect(ImageServiceOperations::Resize).to have_received(:call).with(pipeline:, size: image_request.size,
                                                                          image: Vips::Image)
      expect(ImageServiceOperations::Rotation).to have_received(:call).with(pipeline:,
                                                                            rotation: image_request.rotation)
      expect(ImageServiceOperations::Colorspace).to have_received(:call).with(pipeline:,
                                                                              quality: image_request.quality)
      expect(pipeline).to have_received(:call).with(save: false)
      expect(vips_image).to have_received(:write_to_buffer).with('.jpg[Q=90]')
    end
  end
end
