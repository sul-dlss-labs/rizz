# frozen_string_literal: true

module IdResolvers
  # Basic Id resolver that just returns the full path without the .json extension.
  class Basic
    def self.resolve(url:)
      url.delete_suffix('.json')
    end
  end
end
