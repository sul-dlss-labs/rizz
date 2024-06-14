# frozen_string_literal: true

class FileResolvers
  # Resolves a file using the identifier as the filename.
  class BasicFilename
    def self.resolve(...)
      new(...).resolve
    end

    # @param [String] identifier
    def initialize(identifier:, images_path: Settings.vips_source_resolvers.basic_filename.images_path)
      @identifier = identifier
      @images_path = images_path
    end

    # @return [String] file path
    def resolve
      Rails.logger.info("Resolving file: #{filepath}")
      raise FileResolvers::NotFoundError unless File.exist?(filepath)

      filepath
    end

    private

    attr_reader :identifier, :images_path

    def filepath
      @filepath ||= "#{images_path}/#{identifier}"
    end
  end
end
