ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/db/'
  add_filter 'lib/tasks/'
  add_filter '/vendor/'
  add_filter '/config/'
  add_filter '/app/mailers/'

  add_group "Controllers", "app/controllers"
  add_group "Decorators", "app/decorators"
  add_group "Models", "app/models"
  add_group "QueryObjects", "app/query_objects"
  add_group "ViewObjects", "app/view_objects"

  add_group "Managers", "lib/rorganize/managers"
  add_group "Misc", "lib/rorganize"
end


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
