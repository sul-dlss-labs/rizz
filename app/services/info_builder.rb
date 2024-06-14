# frozen_string_literal: true

# Builds an image information response
class InfoBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(filepath:, id:)
    @filepath = filepath
    @id = id
  end

  def call
    {
      '@context': 'http://iiif.io/api/image/3/context.json',
      id:,
      type: 'ImageService3',
      protocol: 'http://iiif.io/api/image',
      profile: Settings.iiif.profile_level,
      width: image_metadata_service.width,
      height: image_metadata_service.height,
      # Calculated per https://cantaloupe-project.github.io/manual/5.0/endpoints.html#IIIFImageAPI3
      sizes:,
      tiles:
    }
  end

  private

  attr_reader :filepath, :id

  def image_metadata_service
    @image_metadata_service ||= ImageMetadataService.new(filepath:)
  end

  def sizes
    h = image_metadata_service.height
    w = image_metadata_service.width
    sizes = []
    min_size = Settings.iiif.min_size
    while h > min_size && w > min_size
      sizes << { width: w, height: h }
      h /= 2
      w /= 2
    end
    sizes.reverse
  end

  def tiles
    # Not sure if this is correct.
    d = [image_metadata_service.width, image_metadata_service.height].min
    scale_factors = []
    min_size = Settings.iiif.min_size
    scale_factor = 1
    while d > min_size
      scale_factors << scale_factor
      scale_factor *= 2
      d /= 2
    end
    {
      width: Settings.iiif.min_tile_size,
      height: Settings.iiif.min_tile_size,
      scaleFactors: scale_factors
    }
  end
end
