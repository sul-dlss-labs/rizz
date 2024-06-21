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
    # buffer = pdf? ? pdf_buffer : image.write_to_buffer(writer_params)
    ImageResponse.new(mime_type:, image:, writer_params: writer_params)
  end

  attr_reader :image, :format

  # rubocop:disable Metrics/MethodLength
  def writer_params
    case format
    when 'jpg'
      ".jpg[Q=#{Settings.vips.jpeg_quality}]"
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

  def pdf?
    format == 'pdf'
  end

  def pdf_buffer
    # Write via image magick. This is not likely to be awesome.
    # Note that writing to PDF must be enabled in /etc/ImageMagick-?/policy.xml.
    image.magicksave_buffer(format: 'PDF')
  end
end
