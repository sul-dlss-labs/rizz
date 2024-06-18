# frozen_string_literal: true

# Base controller for the application.
class ApplicationController < ActionController::Base
  before_action :set_public_cache
  after_action :set_profile_link

  rescue_from FileResolvers::NotFoundError do
    render status: :not_found, plain: 'Not found'
  end

  def set_public_cache
    return unless Settings.public_cache

    expires_in Settings.public_cache.hours.to_i, public: true
  end

  def set_profile_link
    response.set_header('Link', "http://iiif.io/api/image/3/#{Settings.iiif.profile_level}.json>;rel=\"profile\"")
  end

  def cache
    @cache ||= FileCache.new
  end
end
