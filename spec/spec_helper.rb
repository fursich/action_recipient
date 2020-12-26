require 'bundler/setup'
require 'action_recipient'
require 'mail'
require 'pry'

if RUBY_VERSION >= '2.7.2'
  # NOTE: https://bugs.ruby-lang.org/issues/17000
  # this will keep us informed of deprecation warnings after Ruby 2.7.2
  Warning[:deprecated] = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
