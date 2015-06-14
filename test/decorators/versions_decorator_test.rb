require 'test_helper'

class VersionsDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({versions: {current_page: 1}})

    @project = projects(:projects_001)
    @versions_decorator = @project.versions.decorate(context: {project: @project})
  end

  test "it displays no data when collection is empty" do
    @project.versions.clear
    node(@versions_decorator.display_collection)
    assert_select '#versions-content', 1
    assert_select 'h3', I18n.t(:text_no_versions)
  end

  test "it displays a table when collection contains entries" do
    @project.versions << Version.new(name: 'Version Test')
    @project.save
    @versions_decorator = @project.versions.decorate(context: {project: @project})
    @node = node @versions_decorator.display_collection
    assert_select '#versions-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@versions_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{project_versions_path(@project.slug)}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@versions_decorator.new_link)
    assert_nil @node
  end
end
