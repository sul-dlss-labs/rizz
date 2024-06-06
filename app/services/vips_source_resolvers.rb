# frozen_string_literal: true

# Parent class for VIPS source resolver classes
class VipsSourceResolvers
  class Error < StandardError; end
  class NotFoundError < Error; end
end
