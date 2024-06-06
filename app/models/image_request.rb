# frozen_string_literal: true

# Model for a request to transform an image.
class ImageRequest
  include ActiveModel::Model

  attr_accessor :identifier, :region, :size, :rotation, :quality, :format
end