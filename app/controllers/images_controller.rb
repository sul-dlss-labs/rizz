# frozen_string_literal: true

# Controller for image transformations.
class ImagesController < ApplicationController
  include ActionController::Live

  rescue_from ImageService::InvalidRequestError do |e|
    render status: :bad_request, plain: e.message || 'Invalid request'
  end

  rescue_from ImageService::NotImplementedError do |e|
    render status: :not_implemented, plain: e.message || 'Not implemented'
  end

  # rubocop:disable Metrics/AbcSize
  def show
    filepath = FileResolvers::BasicFilename.resolve(identifier: image_request.identifier)
    if (cache_filepath = cache.find(request:, updated_at: File.mtime(filepath)))
      return send_file cache_filepath, type: request.format, disposition: 'inline'
    end

    begin
      image_response = ImageService.call(filepath:, image_request:)
      response.headers['Content-Type'] = image_response.mime_type
      response.headers['Content-Disposition'] = 'inline'
      image_response.write_to(response.stream)
    ensure
      response.stream.close
    end
    # send_data image_response.buffer, type: image_response.mime_type, disposition: 'inline'
    cache.write(request:, body: image_response.buffer)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def image_params
    params.permit(:identifier, :region, :size, :rotation, :quality, :format)
  end

  def image_request
    @image_request ||= ImageRequest.new(image_params)
  end
end
