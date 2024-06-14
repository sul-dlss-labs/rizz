# frozen_string_literal: true

# Base controller for the application.
class ApplicationController < ActionController::Base
  before_action :set_public_cache

  rescue_from FileResolvers::NotFoundError do
    render status: :not_found, plain: 'Not found'
  end

  def set_public_cache
    return unless Settings.public_cache

    expires_in Settings.public_cache.hours.to_i, public: true
  end

  def cache
    @cache ||= FileCache.new
  end
end
