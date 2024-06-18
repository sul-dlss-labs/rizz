# frozen_string_literal: true

module ImageServiceOperations
  # Performs image cropping.
  class Crop
    def self.call(...)
      new(...).call
    end

    def initialize(pipeline:, image_request:, image:)
      @pipeline = pipeline
      @image_request = image_request
      @image = image
    end

    # rubocop:disable Metrics/AbcSize
    def call
      case region
      when 'full'
        null_crop
      when 'square'
        square_crop
      when /^pct:(\d+),(\d+),(\d+),(\d+)$/
        percentage_crop(::Regexp.last_match(1), ::Regexp.last_match(2), ::Regexp.last_match(3), ::Regexp.last_match(4))
      when /^(\d+),(\d+),(\d+),(\d+)$/
        crop_to(x: ::Regexp.last_match(1).to_i,
                y: ::Regexp.last_match(2).to_i,
                width: ::Regexp.last_match(3).to_i,
                height: ::Regexp.last_match(4).to_i)
      else
        raise ImageService::InvalidRequestError, "Invalid region: #{region}"
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :pipeline, :image_request, :image

    delegate :region, to: :image_request

    # rubocop:disable Metrics/AbcSize
    def square_crop
      if image.width == image.height
        null_crop
      elsif image.width > image.height
        crop_to(x: (image.width - image.height) / 2,
                y: 0,
                width: image.height,
                height: image.height)
      else
        crop_to(x: 0,
                y: (image.height - image.width) / 2,
                width: image.width,
                height: image.width)
      end
    end

    def percentage_crop(x, y, width, height)
      crop_to(x: (image.width * x.to_f) / 100,
              y: (image.height * y.to_f) / 100,
              width: (image.width * width.to_f) / 100,
              height: (image.height * height.to_f) / 100)
    end
    # rubocop:enable Metrics/AbcSize

    def crop_to(x:, y:, width:, height:)
      image_request.crop_height = height
      image_request.crop_width = width
      pipeline.crop(x, y, width, height)
    end

    def null_crop
      image_request.crop_height = image.width
      image_request.crop_width = image.height
      pipeline
    end
  end
end
