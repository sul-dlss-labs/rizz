# frozen_string_literal: true

class VipsSourceResolvers
  # Loads an image from a file on disk using the identifier as the filename.
  class BasicFilename
    def self.resolve(...)
      new(...).resolve
    end

    # @param [ImageRequest] image_request
    def initialize(image_request:)
      @identifier = image_request.identifier
    end

    # @return [Vips::Source]
    def resolve
      Rails.logger.info("Resolving Vips source: #{filepath}")
      raise VipsSourceResolvers::NotFoundError unless File.exist?(filepath)

      Vips::Source.new_from_file(filepath)
    end

    private

    attr_reader :identifier

    def filepath
      "#{Settings.vips_source_resolvers.basic_filename.images_path}/#{identifier}.jp2"
    end
  end
end
