# frozen_string_literal: true

# Model for a response to an image transformation.
class ImageResponse
  include ActiveModel::Model

  attr_accessor :buffer, :mime_type
end
