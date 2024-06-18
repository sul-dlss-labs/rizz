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
        pipeline.resize_to_limit(::Regexp.last_match(1).to_i, nil)
      when /^\^(\d+),$/
        pipeline.resize_to_fit(::Regexp.last_match(1).to_i, nil)
      when /^,(\d+)$/
        pipeline.resize_to_limit(nil, ::Regexp.last_match(1).to_i)
      when /^\^,(\d+)$/
        pipeline.resize_to_fit(nil, ::Regexp.last_match(1).to_i)
      when /^(\d+),(\d+)$/
        pipeline.resize_to_fit([::Regexp.last_match(1).to_i, crop_width].min,
                               [::Regexp.last_match(2).to_i, crop_height].min, size: :force)
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
  end
end
