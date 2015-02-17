# Author: Nicolas Meylan
# Date: 17.02.15 16:25
# Encoding: UTF-8
# File: menu_manager_helper_test.rb
require 'test_helper'
class MenuManagerHelperTest < Rorganize::Decorator::TestCase
  include Rorganize::Managers::MenuManager::MenuHelper
  include ApplicationHelper

  def setup
    @project = projects(:projects_001)

    Rorganize::Managers::MenuManager.clear_menu!(:project_menu_test)
    Rorganize::Managers::MenuManager.map :project_menu_test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'issues', action: 'index'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'projects', action: 'overview'}, {id: 'menu-test-my_action_1'})
    end

    Rorganize::Managers::MenuManager.clear_menu!(:admin_menu_test)
    Rorganize::Managers::MenuManager.map :admin_menu_test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'roles', action: 'index'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'trackers', action: 'index'}, {id: 'menu-test-my_action_1'})
    end

    Rorganize::Managers::MenuManager.clear_menu!(:top_menu_test)
    Rorganize::Managers::MenuManager.map :top_menu_test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'projects', action: 'index'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'administration', action: 'index'}, {id: 'menu-test-my_action_1'})
    end
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "it should display project menu" do
    @menu_context = [:project_menu]
    assert display_main_menu?(@project), 'Project menu can not be displayed'
  end

  test "it should not display project menu when project is nil" do
    @menu_context = [:project_menu]
    assert_not display_main_menu?(nil)
  end

  test "it should display admin menu" do
    @menu_context = [:admin_menu]
    assert display_main_menu?, 'Admin menu can not be displayed'
  end

  test "it should render all project menu" do
    menu = Rorganize::Managers::MenuManager.menu(:project_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    self.stubs(:allowed_to_view_menu_item?).returns(true)

    @menu_context = [:project_menu]
    render_menu(@project)
    node(content_for(:main_menu))
    assert_select 'li', 2
    assert_select 'a', 2
    assert_select 'a[href=?]', issues_path(@project.slug)
    assert_select 'a[href=?]', overview_projects_path(@project.slug)
  end

  test "it should render project menu when user is allowed to access" do
    menu = Rorganize::Managers::MenuManager.menu(:project_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    allow_user_to('index', 'issues')

    @menu_context = [:project_menu]
    render_menu(@project)
    node(content_for(:main_menu))
    assert_select 'li', 1
    assert_select 'a', 1
    assert_select 'a[href=?]', issues_path(@project.slug)
  end

  test "it should render all admin menu" do
    menu = Rorganize::Managers::MenuManager.menu(:admin_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    self.stubs(:allowed_to_view_menu_item?).returns(true)

    @menu_context = [:admin_menu]
    render_menu(@project)
    node(content_for(:main_menu))
    assert_select 'li', 2
    assert_select 'a', 2
    assert_select 'a[href=?]', roles_path
    assert_select 'a[href=?]', trackers_path
  end

  test "it should render admin menu when user is allowed to access" do
    menu = Rorganize::Managers::MenuManager.menu(:admin_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    allow_user_to('index', 'roles')

    @menu_context = [:admin_menu]
    render_menu(@project)
    node(content_for(:main_menu))
    assert_select 'li', 1
    assert_select 'a', 1
    assert_select 'a[href=?]', roles_path
  end

  test "it should render all top menu" do
    menu = Rorganize::Managers::MenuManager.menu(:top_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    self.stubs(:allowed_to_view_top_menu_item?).returns(true)

    @menu_context = [:admin_menu]
    render_top_menu
    node(content_for(:top_menu_items))
    assert_select 'li', 3 # 2 + 1 (home page menu)
    assert_select 'a', 3
    assert_select 'a[href=?]', administration_index_path
    assert_select 'a[href=?]', projects_path
  end

  test "it should render top menu when user is allowed to access" do
    menu = Rorganize::Managers::MenuManager.menu(:top_menu_test)
    Rorganize::Managers::MenuManager.stubs(:menu).returns(menu)
    @view_flow = ActionView::OutputFlow.new
    allow_user_to('index', 'projects')

    @menu_context = [:admin_menu]
    render_top_menu
    node(content_for(:top_menu_items))
    assert_select 'li', 2 # 1 + 1 (home page menu)
    assert_select 'a', 2
    assert_select 'a[href=?]', projects_path
  end
end