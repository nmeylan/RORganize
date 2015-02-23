# Author: Nicolas Meylan
# Date: 23.02.15 18:36
# Encoding: UTF-8
# File: toolbox_helper_test.rb
require 'test_helper'

require 'shared/toolbox'

class ToolboxHelperTest < Rorganize::Helpers::TestCase
  def setup
    @project = projects(:projects_001)

    category1 = Category.create!(name: 'Category 1', project_id: @project.id)
    category2 = Category.create!(name: 'Category 2', project_id: @project.id)

    @issues_statuses = IssuesStatus.all

    @issue1 = Issue.create(tracker_id: 1, subject: 'Issue creation', status_id: '1', project_id: 1, version_id: 1)
    @issue2 = Issue.create(tracker_id: 1, subject: 'Issue creation', status_id: '1', category_id: category1.id, project_id: 1, version_id: 2)
    collection = [@issue1, @issue2]

    @toolbox = Toolbox.new(collection, User.current, {path: 'path_to_hell'})

    @toolbox.extra_actions << link_to('my_extra_option', '#', {id: 'extra-option'})

    @toolbox.generic_toolbox_menu_builder(I18n.t(:field_category), :categories, :category_id, @project.categories, Proc.new(&:category), true)
    @toolbox.generic_toolbox_menu_builder(I18n.t(:field_version), :versions, :version_id, @project.versions, Proc.new(&:version), true)
    @toolbox.generic_toolbox_menu_builder(I18n.t(:field_status), :statuses, :status_id, @issues_statuses, Proc.new(&:status), false)

    @menu_versions = @toolbox.menu[:versions]
    @menu_categories = @toolbox.menu[:categories]
    @menu_statuses = @toolbox.menu[:statuses]
  end

  test 'it builds menu items' do
    node(toolbox_menu_items(@toolbox))
    assert_select 'li' do
      assert_select 'a', text: I18n.t(:field_category)
      assert_select 'a', text: I18n.t(:field_version)
      assert_select 'a', text: I18n.t(:field_status)
      assert_select 'a#categories', 1
      assert_select 'a#versions', 1
      assert_select 'a#statuses', 1
    end
  end

  test 'it builds extra menu items' do
    node(toolbox_extra_menu_item(@toolbox))
    assert_select 'li' do
      assert_select 'a', text: 'my_extra_option'
      assert_select 'a#extra-option', 1
    end
  end

  test 'it build a single menu item' do
    node(toolbox_menu_item(@menu_versions))
    assert_select 'li' do
      assert_select 'a#categories', 0
      assert_select 'a#statuses', 0
      assert_select 'a', text: I18n.t(:field_version)
      assert_select 'a#versions', 1
    end
  end

  test 'it builds sub menu for a given menu item here versions' do
    node(toolbox_sub_menu(@menu_versions))

    assert_select 'ul.submenu.version_id', 1
    assert_select 'input[type=hidden]', 1
    assert_select 'input[type=hidden][name=?]', 'value[version_id]'

    assert_select 'li', @project.versions.size + 1 # + 1 is for The none option
    assert_select 'a', @project.versions.size + 1 # + 1 is for The none option
    assert_select 'a', text: 'None'
    assert_select 'a[data-id=?]', '-1'
    assert_select '.octicon-check', 2 # two issue with their own version id
  end

  test 'it builds sub menu for a given menu item here categories' do
    node(toolbox_sub_menu(@menu_categories))

    assert_select 'ul.submenu.category_id', 1
    assert_select 'input[type=hidden]', 1
    assert_select 'input[type=hidden][name=?]', 'value[category_id]'

    assert_select 'li', @project.categories.size + 1 # + 1 is for The none option
    assert_select 'a', @project.categories.size + 1 # + 1 is for The none option
    assert_select 'a[data-id=?]', '-1'
    assert_select 'a', text: 'None'
    assert_select '.octicon-check', 2 # one issue with its own version id and other with the none
  end

  test 'it builds sub menu for a given menu item here statuses' do
    node(toolbox_sub_menu(@menu_statuses))

    assert_select 'ul.submenu.status_id', 1
    assert_select 'input[type=hidden]', 1
    assert_select 'input[type=hidden][name=?]', 'value[status_id]'

    assert_select 'li', @issues_statuses.size
    assert_select 'a', @issues_statuses.size
    assert_select '.octicon-check', 1
  end
end