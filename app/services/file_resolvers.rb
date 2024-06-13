# frozen_string_literal: true

# Parent class for file resolver classes
class FileResolvers
  class Error < StandardError; end
  class NotFoundError < Error; end
end
