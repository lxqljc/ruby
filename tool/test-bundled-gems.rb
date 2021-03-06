require 'rbconfig'

allowed_failures = ENV['TEST_BUNDLED_GEMS_ALLOW_FAILURES'] || ''
allowed_failures = allowed_failures.split(',').reject(&:empty?)

rake = File.realpath("../../.bundle/bin/rake", __FILE__)
gem_dir = File.realpath('../../gems', __FILE__)
exit_code = 0
ruby = ENV['RUBY'] || RbConfig.ruby
File.foreach("#{gem_dir}/bundled_gems") do |line|
  gem = line.split.first
  puts "\nTesting the #{gem} gem"

  test_command = "#{ruby} -C #{gem_dir}/src/#{gem} -Ilib #{rake}"
  puts test_command
  system test_command

  unless $?.success?
    puts "Tests failed with exit code #{$?.exitstatus}"
    if allowed_failures.include?(gem)
      puts "Ignoring test failures for #{gem} due to \$TEST_BUNDLED_GEMS_ALLOW_FAILURES"
    else
      exit_code = $?.exitstatus
    end
  end
end

exit exit_code
