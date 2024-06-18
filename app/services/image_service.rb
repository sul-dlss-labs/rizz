# frozen_string_literal: true

# Converts an image request into an image response using VIPs
class ImageService
  class Error < StandardError; end
  class NotImplementedError < Error; end
  class InvalidRequestError < Error; end

  def self.call(...)
    new(...).call
  end

  def initialize(image_request:, filepath:)
    @image_request = image_request
    @filepath = filepath
  end

  def pipeline
    pipeline = ImageProcessing::Vips
               .source(source_image)
    pipeline = ImageServiceOperations::Crop.call(pipeline:, image_request:, image: source_image)
    pipeline = ImageServiceOperations::Resize.call(pipeline:, image_request:, image: source_image)
    pipeline = ImageServiceOperations::Rotation.call(pipeline:, rotation: image_request.rotation)
    ImageServiceOperations::Colorspace.call(pipeline:, quality: image_request.quality)
  end

  def call
    image = pipeline.call(save: false)
    VipsBufferWriter.call(image:, format: image_request.format)
  end

  private

  attr_reader :image_request, :filepath, :image

  def source_image
    @source_image ||= Vips::Image.new_from_source(Vips::Source.new_from_file(filepath), '').tap do |image|
      if image.get('vips-loader') == 'jp2kload_source' && Settings.kakadu.check_loader
        raise 'Using OpenJPEG for JP2s, not Kakadu'
      end
    end
  end
end
