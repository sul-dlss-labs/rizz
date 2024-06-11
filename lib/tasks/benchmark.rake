# frozen_string_literal: true

require 'benchmark'
include Benchmark # rubocop:disable Style/MixinUsage

desc 'Benchmark transforming an image'
task :benchmark,
     %i[identifier region size rotation quality format runs images_path] => :environment do |_task, args|
  image_request = ImageRequest.new(args.to_h.except(:runs, :images_path))
  images_path = args[:images_path] || Settings.vips_source_resolvers.basic_filename.images_path
  ActiveRecord::Base.logger.silence do
    Benchmark.benchmark(CAPTION, 7, FORMAT, '>total:', '>avg:') do |bm|
      report_sum = nil
      args[:runs].to_i.times do |index|
        report = bm.report("Run #{index + 1}") do
          vips_source = VipsSourceResolvers::BasicFilename.resolve(image_request:, images_path:)
          ImageService.call(image_request:, vips_source:)
        end
        report_sum = report_sum ? report_sum + report : report
      end
      [report_sum, report_sum / args[:runs].to_f]
    end
  end
end
