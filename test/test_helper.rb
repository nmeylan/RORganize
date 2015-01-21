ENV['RAILS_ENV'] = 'test'
if ENV['COVERAGE']
  require 'simplecov'
  require 'code_coverage'
  CodeCoverage.start
end
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'test_assertions/test_assertions'

class ActionController::TestCase
  include Devise::TestHelpers
  setup do
    User.current = users(:users_001)
    User.any_instance.stubs(:allowed_to?).returns(true)
  end
end

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

class Object
  def self.stub_any_instance(name, val_or_callable, &block)
    new_name = "__minitest_any_instance_stub__#{name}"

    class_eval do
      alias_method new_name, name

      define_method(name) do |*args|
        if val_or_callable.respond_to?(:call)
          val_or_callable.call(*args)
        else
          val_or_callable
        end
      end
    end

    yield
  ensure
    class_eval do
      undef_method(name)
      alias_method(name, new_name)
      undef_method(new_name)
    end
  end
end
