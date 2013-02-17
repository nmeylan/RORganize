ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

require 'rails/test_help'
require 'test/unit/ui/console/testrunner'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'
require 'issue'
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
