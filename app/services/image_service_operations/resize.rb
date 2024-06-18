# frozen_string_literal: true

module ImageServiceOperations
  # Performs image resizing.
  class Resize
    def self.call(...)
      new(...).call
    end

    def initialize(pipeline:, image_request:, image:)
      @pipeline = pipeline
      @image_request = image_request
      @image = image
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def call
      case size
      when 'max'
        pipeline
      when '^max'
        pipeline.resize_to_fit(image.width, image.height)
      when /^(\d+),$/
        width = ::Regexp.last_match(1).to_i
        check_dimension(width, crop_width)
        pipeline.resize_to_limit(width, nil)
      when /^\^(\d+),$/
        width = ::Regexp.last_match(1).to_i
        pipeline.resize_to_fit(width, nil)
      when /^,(\d+)$/
        height = ::Regexp.last_match(1).to_i
        check_dimension(height, crop_height)
        pipeline.resize_to_limit(nil, height)
      when /^\^,(\d+)$/
        height = ::Regexp.last_match(1).to_i
        pipeline.resize_to_fit(nil, height)
      when /^(\d+),(\d+)$/
        width = ::Regexp.last_match(1).to_i
        check_dimension(width, crop_width)
        height = ::Regexp.last_match(2).to_i
        check_dimension(height, crop_height)
        pipeline.resize_to_fit(width, height, size: :force)
      else
        raise ImageService::InvalidRequestError, "Invalid size: #{size}"
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    attr_reader :image_request, :pipeline, :image

    delegate :size, :crop_height, :crop_width, to: :image_request

    def check_dimension(dimension, max)
      raise ImageService::InvalidRequestError, 'Invalid size' if dimension > max
    end
  end
end
