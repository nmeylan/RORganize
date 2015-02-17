# Author: Nicolas Meylan
# Date: 17.02.15 20:46
# Encoding: UTF-8
# File: module_manager_helper_test.rb
require 'test_helper'

class ModuleManagerHelperTest < ActiveSupport::TestCase
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = Project.create!(name: 'test project')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "project has not enabled module" do
    assert_not module_enabled?(@project.id, 'index', 'test_controller')
  end

  test "project has enabled module" do
    assert_not module_enabled?(@project.id, 'index', 'test_controller')

    @project.enabled_modules << EnabledModule.new(controller: 'test_controller', action: 'index', name: 'my_module_name2')
    @project.save
    Rorganize::Managers::ModuleManager::reload_enabled_modules(@project.id.to_s)

    assert module_enabled?(@project.id, 'index', 'test_controller')
  end

  test "it exists always enabled module" do
    assert_not module_enabled?(@project.id, 'index', 'test11_controller')

    Rorganize::Managers::ModuleManager::add_always_enabled_modules([{controller: 'test11_controller', action: 'index'}])

    assert module_enabled?(@project.id, 'index', 'test11_controller')
  end

  test "project has enabled module through association" do
    assert_not module_enabled?(@project.id, 'show', 'test_controller')

    @project.enabled_modules << EnabledModule.new(controller: 'test_controller', action: 'edit', name: 'my_module_name2')
    @project.save
    Rorganize::Managers::ModuleManager::set_associations_actions_module({'my_module_name2' => {'test_controller' => ['show']}})
    Rorganize::Managers::ModuleManager::reload_enabled_modules(@project.id.to_s)

    assert module_enabled?(@project.id, 'edit', 'test_controller')
    assert module_enabled?(@project.id, 'show', 'test_controller')
  end
end