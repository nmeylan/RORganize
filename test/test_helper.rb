ENV['RAILS_ENV'] ||= 'test'
if ENV['COVERAGE']
  require 'simplecov'
  require 'code_coverage'
  CodeCoverage.start
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'awsome_reporter'
require 'mocha/mini_test'
require 'test_assertions/test_assertions'
require 'test_utilities/custom_http_request'
require 'test_utilities/generic_controllers_test_cases'
require 'test_utilities/user_grant_permissions'
require 'test_utilities/decorator_test_case'
require 'test_utilities/helpers_test_case'

# Initialize reporter.
Minitest::Reporters.use! [Minitest::Reporters::AwesomeReporter.new({color: true, slow_count: 5})]

class ActionController::TestCase
  include Rorganize::CustomHttpRequest
  include Rorganize::GenericControllersTestCases
  include Devise::TestHelpers
  include Rorganize::UserGrantPermissions

  setup do
    @request.env['HTTP_REFERER'] = 'http://test.com/'
    User.any_instance.stubs(:module_enabled?).returns(true)
    User.stubs(:current).returns(users(:users_001))

    sign_in User.current
    drop_all_user_permissions
  end
end

class ActiveSupport::TestCase
  include Rorganize::TestAssertions
  include Rorganize::UserGrantPermissions
  fixtures :all

  setup do
    User.current = users(:users_001)
    User.any_instance.stubs(:generate_default_avatar).returns(nil)
    drop_all_user_permissions
  end

  # Test cases methods
  def generate_string_of_length(length)
    (0...length).map { (65 + rand(26)).chr }.join
  end

  def is_mysql?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
  end

  def is_sqlite?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')
  end

  def is_pg?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
  end
end
