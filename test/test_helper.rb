ENV['RAILS_ENV'] = 'test'
if ENV['COVERAGE']
  require 'simplecov'
  require 'code_coverage'
  CodeCoverage.start
end
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'test_assertions/test_assertions'


class ActiveSupport::TestCase
  include Rorganize::TestAssertions
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  setup do
    User.current = users(:users_001)
  end
  # Add more helper methods to be used by all tests here...

  def generate_string_of_length(length)
    (0...length).map { (65 + rand(26)).chr }.join
  end
end

