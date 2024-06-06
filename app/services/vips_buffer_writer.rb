# frozen_string_literal: true

# Writes a Vips::Image to a buffer in a specified format.
class VipsBufferWriter
  def self.call(...)
    new(...).call
  end

  # @param [Vips::Image] image
  def initialize(image:, format:)
    @image = image
    @format = format
  end

  # @return [ImageResponse]
  def call
    buffer = image.write_to_buffer(writer_params)
    ImageResponse.new(buffer:, mime_type:)
  end

  attr_reader :image, :format

  # rubocop:disable Metrics/MethodLength
  def writer_params
    case format
    when 'jpg'
      '.jpg[Q=90]'
    when 'png'
      '.png'
    when 'webp'
      '.webp'
    when 'jp2'
      '.jp2'
    when 'tif'
      '.tif'
    when 'gif'
      '.gif'
    else
      raise ImageService::InvalidRequestError, "Unsupported format: #{format}"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def mime_type
    Rack::Mime::MIME_TYPES[".#{format}"]
  end
end
