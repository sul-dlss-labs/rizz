# frozen_string_literal: true

# Controller for image information requests.
class InfoController < ApplicationController
  CONTENT_TYPE = 'application/ld+json; profile="http://iiif.io/api/image/3/context.json"; charset=utf-8'

  # rubocop:disable Metrics/AbcSize
  def show
    filepath = FileResolvers::BasicFilename.resolve(identifier: params[:identifier])
    if (cache_filepath = cache.find(request:, updated_at: File.mtime(filepath)))
      return send_file cache_filepath, content_type: CONTENT_TYPE, disposition: 'inline'
    end

    id = IdResolvers::Basic.resolve(url: request.url)
    info_response = InfoBuilder.call(filepath:, id:)
    render json: info_response, content_type: CONTENT_TYPE
    cache.write(request:, body: info_response.to_json)
  end
  # rubocop:enable Metrics/AbcSize
end
