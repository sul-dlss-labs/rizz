# frozen_string_literal: true

# Extract image metadata using VIPS.
class ImageMetadataService
  def initialize(filepath:)
    @filepath = filepath
  end

  def height
    @height ||= source_image.get('height')
  end

  def width
    @width ||= source_image.get('width')
  end

  private

  attr_reader :filepath

  def source_image
    @source_image ||= Vips::Image.new_from_source(Vips::Source.new_from_file(filepath), '')
  end
end
