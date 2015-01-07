ENV['RAILS_ENV'] = 'test'
if ENV['COVERAGE']
  require 'simplecov'
  require 'code_coverage'
  CodeCoverage.start
end
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'




class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  setup do
    User.current = users(:users_001)
  end
  # Add more helper methods to be used by all tests here...
end

