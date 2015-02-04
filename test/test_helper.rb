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
  fixtures :all

  setup do
    User.current = users(:users_001)
    User.any_instance.stubs(:generate_default_avatar).returns(nil)
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
end

module Rorganize
  module HTMLTesting
    def node(html)
      Nokogiri::HTML::Document.parse(html).root
    end
  end
end

module Rorganize
  module Decorator
    class TestCase < Draper::TestCase
      include Rorganize::HTMLTesting
      include Rails::Dom::Testing::Assertions
      include ActionDispatch::Assertions
      include Rorganize::UserGrantPermissions

      def initialize(test_case)
        super(test_case)
        @node = nil #should be defined just before calling assert_select
        @routes = Rails.application.routes
        @controller_class = self.class.determine_default_controller_class(self.class.name)
        @controller = @controller_class.new
        @controller.request = ActionController::TestRequest.new
        @controller_name = @controller.controller_name
        @controller.instance_variable_set(:@sessions, {@controller_name.to_sym => {}})
      end

      setup do
        Draper::ViewContext.current = @controller.view_context
        User.stubs(:current).returns(users(:users_001))
        sign_in User.current
        drop_all_user_permissions
      end

      def node(html)
        @node = super(html)
      end

      def document_root_element
        @node #should be defined just before calling assert_select
      end

      class << self
        def determine_default_controller_class(name)
          determine_constant_from_test_name(name) do |constant|
            Class === constant && constant < ActionController::Metal
          end
        end

        def determine_constant_from_test_name(test_name)
          names = test_name.split "::"
          while names.size > 0 do
            name = names.last
            name.sub!(/DecoratorTest$/, "")
            name = name.pluralize
            name = "#{name}Controller"
            names[names.size - 1] = name
            begin
              constant = names.join("::").safe_constantize
              break(constant) if yield(constant)
            ensure
              names.pop
            end
          end
        end
      end
    end
  end
end
