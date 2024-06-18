# frozen_string_literal: true

# Model for a request to transform an image.
class ImageRequest
  include ActiveModel::Model

  attr_accessor :identifier, :region, :size, :rotation, :quality, :format
  # These are added by the crop operation
  attr_accessor :crop_height, :crop_width
end
