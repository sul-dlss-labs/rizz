# frozen_string_literal: true

module ImageServiceOperations
  # Performs image rotation.
  class Rotation
    def self.call(...)
      new(...).call
    end

    def initialize(pipeline:, rotation:)
      @pipeline = pipeline
      @rotation = rotation
    end

    def call
      matcher = /^!?(\d+)$/.match(rotation)
      raise ImageService::InvalidRequestError, "Invalid rotation: #{rotation}" unless matcher

      @pipeline = @pipeline.flip(:horizontal) if rotation.starts_with? '!'
      @pipeline = @pipeline.rotate(::Regexp.last_match(1).to_i) if matcher[1] != '0'
      @pipeline
    end

    private

    attr_reader :rotation
  end
end
