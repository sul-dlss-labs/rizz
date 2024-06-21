# frozen_string_literal: true

# Model for a response to an image transformation.
class ImageResponse
  # include ActiveModel::Model

  # attr_accessor :writer, :mime_type
  def initialize(mime_type:, image:, writer_params: nil)
    @mime_type = mime_type
    @image = image
    @writer_params = writer_params
  end

  def write_to(stream)
    @buffer = ''.dup
    target = Vips::TargetCustom.new
    target.on_write do |bytes|
      stream.write bytes
      @buffer << bytes
      # Need one of the following 2 lines
      # Rails.logger.info("x")
      puts 'x'
      bytes.length
    end
    image.write_to_target target, writer_params
  end

  def buffer
    @buffer ||= image.write_to_buffer(writer_params)
  end

  attr_reader :mime_type

  private

  attr_reader :image, :writer_params
end
