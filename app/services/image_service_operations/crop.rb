# frozen_string_literal: true

module ImageServiceOperations
  # Performs image cropping.
  class Crop
    def self.call(...)
      new(...).call
    end

    def initialize(pipeline:, region:, image:)
      @pipeline = pipeline
      @region = region
      @image = image
    end

    # rubocop:disable Metrics/AbcSize
    def call
      case region
      when 'full'
        pipeline
      when 'square'
        square_crop
      when /^pct:(\d+),(\d+),(\d+),(\d+)$/
        percentage_crop(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3), ::Regexp.last_match(4))
      when /^(\d+),(\d+),(\d+),(\d+)$/
        pipeline.crop(::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i, ::Regexp.last_match(3).to_i,
                      ::Regexp.last_match(4).to_i)
      else
        raise ImageService::InvalidRequestError, "Invalid region: #{region}"
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :pipeline, :region, :image

    # rubocop:disable Metrics/AbcSize
    def square_crop
      if image.width == image.height
        nil
      elsif image.width > image.height
        pipeline.crop((image.width - image.height) / 2, 0, image.height, image.height)
      else
        pipeline.crop(0, (image.height - image.width) / 2, image.width, image.width)
      end
    end

    def percentage_crop(x, y, width, height)
      pipeline.crop((image.width * x.to_f) / 100, (image.height * y.to_f) / 100, (image.width * width.to_f) / 100,
                    (image.height * height.to_f) / 100)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
