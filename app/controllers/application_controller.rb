# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def set_public_cache
    return unless Settings.public_cache

    expires_in Settings.public_cache.hours.to_i, public: true
  end
end
