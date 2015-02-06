require 'test_helper'

class IssuesDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)

    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)
    helpers.stubs(:session).returns({issues: {current_page: 1}})

    @issues_decorator = @project.issues.decorate(context: {project: @project})
    @controller.instance_variable_set(:@project, @project)
  end

  test "it displays no data when collection is empty" do
    @project.issues.clear
    node(@issues_decorator.display_collection)
    assert_select '#issues-content', 1
    assert_select 'h3', I18n.t(:text_no_issues)
  end

  test "it displays a table when collection contains entries" do
    @project.issues.clear
    @project.issues << Issue.new(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: @project.id)
    @project.save
    @issues_decorator = @project.issues.decorate(context: {project: @project})
    node(@issues_decorator.display_collection)
    assert_select '#issues-content', 1
    assert_select 'table', 1
  end

  test "it displays pagination when there are more than 25 entries" do
    assert @project.issues.size > 25
    issues = Issue.prepare_paginated(1, 25, 'issues.id ASC', '', @project.id)
    @issues_decorator = issues.decorate(context: {project: @project})
    @issues_decorator.stubs(:pagination_path).returns('number_of_entries_path')
    helpers.stubs(:paginate).returns('<div class=\'pagination\'>pagination</div>'.html_safe)
    node(@issues_decorator.display_collection)
    assert_select '#issues-content', 1
    assert_select 'table', 1
    assert_select '.pagination', text: 'pagination'
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@issues_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{issues_path(@project.slug)}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@issues_decorator.new_link)
    assert_nil @node
  end
end
