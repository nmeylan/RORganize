# Author: Nicolas Meylan
# Date: 19.02.15 18:33
# Encoding: UTF-8
# File: url_manager_test.rb
require 'rails/engine'

require 'test_helper'

class UrlManagerTest < ActionDispatch::IntegrationTest
  include Rorganize::Managers::UrlManager

  class StubDispatcher < ::ActionDispatch::Routing::RouteSet::Dispatcher
    protected
    def controller_reference(controller_param)
      controller_param
    end

    def dispatch(controller, action, env)
      [200, {'Content-Type' => 'text/html'}, ["#{controller}##{action}"]]
    end
  end

  def self.stub_controllers
    old_dispatcher = ActionDispatch::Routing::RouteSet::Dispatcher
    ActionDispatch::Routing::RouteSet.module_eval { remove_const :Dispatcher }
    ActionDispatch::Routing::RouteSet.module_eval { const_set :Dispatcher, StubDispatcher }
    yield ActionDispatch::Routing::RouteSet.new
  ensure
    ActionDispatch::Routing::RouteSet.module_eval { remove_const :Dispatcher }
    ActionDispatch::Routing::RouteSet.module_eval { const_set :Dispatcher, old_dispatcher }
  end

  class DummyEngine < Rails::Engine
    def self.routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
    end

    def set_routes(routes)
      @routes = routes
    end
  end

  disable_clear_and_finalize = Rails.application.routes.disable_clear_and_finalize
  Rails.application.routes.disable_clear_and_finalize = true

  stub_controllers do
    DummyEngine.routes.draw do
      Rails.application.routes.draw do
        mount DummyEngine => '/', as: 'dummy_engine'

        scope 'test_scope/:project_id' do
          resources :cars
        end
      end
      scope 'test_scope/:project_id' do
        resources :dummies
      end
    end

    DummyEngine.instance.set_routes(DummyEngine.routes)
  end

  Rails.application.routes.disable_clear_and_finalize = disable_clear_and_finalize

  test "it recognize index path for a core app resource" do
    path_recognition_result = recognize_path(cars_path('rorganize'), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'index', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
  end

  test "it recognize create path for a core app resource" do
    path_recognition_result = recognize_path(cars_path('rorganize'), {method: :post})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'create', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
  end

  test "it recognize edit path for a core app resource" do
    path_recognition_result = recognize_path(edit_car_path('rorganize', 666), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'edit', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize update path for a core app resource" do
    path_recognition_result = recognize_path(car_path('rorganize', 666), {method: :put})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'update', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize show path for a core app resource" do
    path_recognition_result = recognize_path(car_path('rorganize', 666), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'show', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize delete path for a core app resource" do
    path_recognition_result = recognize_path(car_path('rorganize', 666), {method: :delete})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'cars', path_recognition_result[:controller]
    assert_equal 'destroy', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::dummies_path('rorganize'), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'index', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
  end

  test "it recognize create path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::dummies_path('rorganize'), {method: :post})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'create', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
  end

  test "it recognize edit path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::edit_dummy_path('rorganize', 666), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'edit', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize update path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::dummy_path('rorganize', 666), {method: :put})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'update', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize show path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::dummy_path('rorganize', 666), {method: :get})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'show', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it recognize delete path for an engine resource" do
    path_recognition_result = recognize_path(dummy_engine::dummy_path('rorganize', 666), {method: :delete})
    assert path_recognition_result.is_a?(Hash)
    assert_equal 'dummies', path_recognition_result[:controller]
    assert_equal 'destroy', path_recognition_result[:action]
    assert_equal 'rorganize', path_recognition_result[:project_id]
    assert_equal '666', path_recognition_result[:id]
  end

  test "it build an url for index path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars', url_for_with_engine_lookup(controller: 'cars', action: 'index', project_id: 'rorganize', only_path: true)
  end

  test "it build an url for create path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars', url_for_with_engine_lookup(controller: 'cars', action: 'create', project_id: 'rorganize', only_path: true)
  end

  test "it build an url for edit path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars/666/edit', url_for_with_engine_lookup(controller: 'cars', action: 'edit', project_id: 'rorganize', id: 666, only_path: true)
  end

  test "it build an url for update path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars/666', url_for_with_engine_lookup(controller: 'cars', action: 'update', project_id: 'rorganize', id: 666, only_path: true)
  end

  test "it build an url for show path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars/666', url_for_with_engine_lookup(controller: 'cars', action: 'show', project_id: 'rorganize', id: 666, only_path: true)
  end

  test "it build an url for delete path for a core app resource" do
    assert_equal '/test_scope/rorganize/cars/666', url_for_with_engine_lookup(controller: 'cars', action: 'destroy', project_id: 'rorganize', id: 666, only_path: true)
  end

  test "it build an url for index path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies', url_for_with_engine_lookup(controller: 'dummies', action: 'index', project_id: 'rorganize')
  end

  test "it build an url for create path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies', url_for_with_engine_lookup(controller: 'dummies', action: 'create', project_id: 'rorganize')
  end

  test "it build an url for edit path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies/666/edit', url_for_with_engine_lookup(controller: 'dummies', action: 'edit', project_id: 'rorganize', id: 666)
  end

  test "it build an url for update path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies/666', url_for_with_engine_lookup(controller: 'dummies', action: 'update', project_id: 'rorganize', id: 666)
  end

  test "it build an url for show path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies/666', url_for_with_engine_lookup(controller: 'dummies', action: 'show', project_id: 'rorganize', id: 666)
  end

  test "it build an url for delete path for an engine resource" do
    assert_equal '/test_scope/rorganize/dummies/666', url_for_with_engine_lookup(controller: 'dummies', action: 'destroy', project_id: 'rorganize', id: 666)
  end

end
