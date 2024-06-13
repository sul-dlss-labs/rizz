# frozen_string_literal: true

# Controller for image transformations.
class ImagesController < ApplicationController
  before_action :set_public_cache

  rescue_from VipsSourceResolvers::NotFoundError do
    render status: :not_found, plain: 'Not found'
  end

  rescue_from ImageService::InvalidRequestError do |e|
    render status: :bad_request, plain: e.message || 'Invalid request'
  end

  rescue_from ImageService::NotImplementedError do |e|
    render status: :not_implemented, plain: e.message || 'Not implemented'
  end

  def show
    image_request = ImageRequest.new(image_params)
    vips_source = VipsSourceResolvers::BasicFilename.resolve(image_request:)
    image_response = ImageService.call(image_request:, vips_source:)
    send_data image_response.buffer, type: image_response.mime_type, disposition: 'inline'
  end

  private

  def image_params
    params.permit(:identifier, :region, :size, :rotation, :quality, :format)
  end
end
