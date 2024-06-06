# frozen_string_literal: true

# Converts an image request into an image response using VIPs
class ImageService
  class Error < StandardError; end
  class NotImplementedError < Error; end
  class InvalidRequestError < Error; end

  def self.call(...)
    new(...).call
  end

  def initialize(image_request:, vips_source:)
    @image_request = image_request
    @vips_source = vips_source
  end

  # rubocop:disable Metrics/AbcSize
  def call
    source_image = Vips::Image.new_from_source(vips_source, '')
    pipeline = ImageProcessing::Vips
               .source(source_image)
    pipeline = ImageServiceOperations::Crop.call(pipeline:, region: image_request.region, image: source_image)
    pipeline = ImageServiceOperations::Resize.call(pipeline:, size: image_request.size, image: source_image)
    pipeline = ImageServiceOperations::Rotation.call(pipeline:, rotation: image_request.rotation)
    pipeline = ImageServiceOperations::Colorspace.call(pipeline:, quality: image_request.quality)
    Rails.logger.info("Image: #{pipeline.inspect}")
    image = pipeline.call(save: false)
    VipsBufferWriter.call(image:, format: image_request.format)
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :image_request, :vips_source, :image
end
