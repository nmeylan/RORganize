# Author: Nicolas Meylan
# Date: 17.02.15 19:05
# Encoding: UTF-8
# File: module_manager_test.rb
require 'test_helper'

class ModuleManagerTest < ActiveSupport::TestCase

  def setup
    @project = Project.create!(name: 'test project')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "it defines a panel with many modules" do
    panel = initialize_test_panel
    assert_equal 2, panel.modules.size
  end

  test "it clear all defined module for the panel" do
    panel = initialize_test_panel
    assert_equal 2, panel.modules.size
    panel.clear_all!
    assert_equal 0, panel.modules.size
  end

  test "it loads all enable test_panel modules for the given project" do
    panel = initialize_test_panel
    assert_equal 0, panel.enabled_modules[@project.id.to_s].size

    @project.enabled_modules.clear
    @project.enabled_modules << EnabledModule.new(controller: 'my_module_controller', action: 'my_action', name: 'my_module_name')
    @project.enabled_modules << EnabledModule.new(controller: 'my_module_controller2', action: 'my_action2', name: 'my_module_name2')
    @project.save
    panel.load_enabled_modules_spec_project(@project.id.to_s)

    assert_equal 2, panel.enabled_modules[@project.id.to_s].size
  end

  test "it clear all enabled modules for the given project" do
    panel = initialize_test_panel
    assert_equal 0, panel.enabled_modules[@project.id.to_s].size

    @project.enabled_modules.clear
    @project.enabled_modules << EnabledModule.new(controller: 'my_module_controller', action: 'my_action', name: 'my_module_name')
    @project.enabled_modules << EnabledModule.new(controller: 'my_module_controller2', action: 'my_action2', name: 'my_module_name2')
    @project.save
    panel.load_enabled_modules_spec_project(@project.id.to_s)
    assert_equal 2, panel.enabled_modules[@project.id.to_s].size
    panel.clear_all_for_project!(@project)
    assert_equal 0, panel.enabled_modules[@project.id.to_s].size
  end

  test "it can add always enable modules" do
    assert_difference(-> {Rorganize::Managers::ModuleManager::always_enabled_modules.size}, 1) do
      Rorganize::Managers::ModuleManager.add_always_enabled_modules([{controller: 'tests_controller', action: 'index'}])
    end
  end

  private
  def initialize_test_panel
    Rorganize::Managers::ModuleManager::clear_panel_modules(:test_panel)
    Rorganize::Managers::ModuleManager.map :test_panel do |mod|
      mod.add('My_Module_Name', 'my_module_controller', 'my_action')
      mod.add('My_Module_Name2', 'my_module_controller2', 'my_action2')
    end
    Rorganize::Managers::ModuleManager.panel(:test_panel)
  end
end