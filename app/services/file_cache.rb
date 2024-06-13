# frozen_string_literal: true

# A simple file cache that stores files on disk.
# Files are stored in a directory structure that mirrors the request path.
# If updated_at is provided, the cache is self-expiring and will not return stale files.
class FileCache
  def initialize(cache_path: Settings.file_cache.path || Rails.root.join('tmp/file_cache'))
    @cache_path = cache_path
    @@file_extensions ||= Rack::Mime::MIME_TYPES.invert # rubocop:disable Style/ClassVars
  end

  # Finds a file in the cache.
  # If updated_at is provided, the cache will only return the cached file if it is newer than updated_at.
  # The cache file will also be touched to update its modified time.
  # If older, the cached file will be deleted from the cache.
  # @param [ActionDispatch::Request] request the request to look up in the cache.
  # @param [Time, nil] updated_at the time the cached item was last updated.
  # @return [String, nil] the filepath of the cached file, or nil if the file is not cached or is stale.
  def find(request:, updated_at: nil)
    return unless Settings.file_cache.enabled

    path = file_cache_path(request)
    return unless File.exist?(path)

    if updated_at && File.mtime(path) < updated_at
      Rails.logger.info("Cache stale: #{path}")
      File.delete(path)
      return
    end
    Rails.logger.info("Cache hit: #{path}")
    FileUtils.touch(path)
    path
  end

  def write(request:, body:)
    return unless Settings.file_cache.enabled

    path = file_cache_path(request)
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, body)
    Rails.logger.info("Wrote cache: #{path}")
  end

  private

  def file_cache_path(request)
    path = File.join(@cache_path, request.path)
    ext = @@file_extensions[request.format.to_s]
    path << ext if File.extname(path).empty? && ext
    path
  end
end
