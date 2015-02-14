require 'test_helper'

class ProjectsDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @projects = Project.all
    @project = projects(:projects_001)
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)

    @projects_decorator = @projects.decorate
  end

  test "it displays no data when collection is empty" do
    @projects_decorator = Project.where('1=2').decorate
    node(@projects_decorator.display_collection)
    assert_select '#projects-content', 1
    assert_select 'h3', I18n.t(:no_data_projects)
  end

  test "it displays a fancy list of projects" do
    node(@projects_decorator.display_collection)
    assert_select '#projects-content', 1
    assert_select 'ul.project-list', 1
    assert_select 'a[href=?]', overview_projects_path(@project.slug)
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@projects_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{projects_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@projects_decorator.new_link)
    assert_nil @node
  end
end
