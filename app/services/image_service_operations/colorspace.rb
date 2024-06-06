# frozen_string_literal: true

module ImageServiceOperations
  # Change an image's colorspace.
  class Colorspace
    def self.call(...)
      new(...).call
    end

    def initialize(pipeline:, quality:)
      @pipeline = pipeline
      @quality = quality
    end

    def call
      case quality
      when 'default', 'color'
        pipeline
      when 'gray'
        pipeline.colourspace(:grey16)
      when 'bitonal'
        pipeline.colourspace(:b_w)
      else
        raise ImageService::InvalidRequestError, "Invalid quality: #{quality}"
      end
    end

    private

    attr_reader :pipeline, :quality
  end
end
