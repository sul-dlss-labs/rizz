# frozen_string_literal: true

# Controller for image information requests.
class InfoController < ApplicationController
  def show
    # TODO: Add caching
    # TODO: Add compression to caching for json.

    filepath = FileResolvers::BasicFilename.resolve(identifier: params[:identifier])
    id = IdResolvers::Basic.resolve(url: request.url)
    info_response = InfoBuilder.call(filepath:, id:)
    render json: info_response, content_type: 'application/ld+json; profile="http://iiif.io/api/image/3/context.json"'
  end
end
