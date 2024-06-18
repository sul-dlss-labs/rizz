# frozen_string_literal: true

namespace :cache do
  # desc "Clears all files and directories in tmp/cache"
  task clear: :environment do |_task, _args|
    unless Dir.exist?(Settings.file_cache.path) || File.symlink?(Settings.file_cache.path)
      raise 'Cache directory does not exist'
    end

    FileUtils.rm_rf(Dir["#{Settings.file_cache.path}/[^.]*"])
  end
end
