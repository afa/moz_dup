require 'simplecov'
require 'simplecov-cobertura'
SimpleCov.profiles.define 'ruby' do
end

SimpleCov.enable_coverage :branch
SimpleCov.primary_coverage :branch

SimpleCov.start('ruby') do
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::SimpleFormatter,
                                                      SimpleCov::Formatter::CoberturaFormatter])
  # add_filter do |source_file|
  #   source_file.lines.count < 5
  # end
  # add_filter %r{^/app/admin/}
  # add_filter %r{^/config/}
  # add_filter %r{^/lib/core/}
  # add_filter %r{^/db/}
  # add_filter %r{^/lib/tasks}
  # add_group 'CMD', 'app/commands'
  # add_group 'SER', 'app/serializers'
  # add_group 'resque', 'app/jobs'
  # add_group 'sneakers', 'app/workers'
  # add_group 'p1', 'app/controllers/p1'
  # add_group 'e1', 'app/controllers/api/e1'
  # add_group 'v1', 'app/controllers/api/v1'
  # add_group 'v2', 'app/controllers/api/v2'
end
# Print SimpleCov report after all parallel tests are finished.
# See https://github.com/grosser/parallel_tests/wiki#with-simplecov----by-a-grateful-user
# if ENV['TEST_ENV_NUMBER']
#   SimpleCov.at_exit do
#     result = SimpleCov.result
#     result.format! if ParallelTests.number_of_running_processes <= 1
#   end
# end
