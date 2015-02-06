require 'test_helper'

class MembersDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({members: {current_page: 1}})

    @project = projects(:projects_001)
    @members_decorator = @project.members.decorate(context: {project: @project})
  end

  test "it displays no data when collection is empty" do
    @project.members.clear
    node(@members_decorator.display_collection)
    assert_select '#members-content', 1
    assert_select 'h3', I18n.t(:text_no_data)
  end

  test "it displays a table when collection contains entries" do
    @project.members.clear
    @project.members << Member.create(user_id: User.current.id, project_id: @project.id, role_id: roles(:roles_001).id)

    @members_decorator = @project.members.decorate(context: {project: @project})
    @node = node @members_decorator.display_collection
    assert_select '#members-content', 1
    assert_select 'table', 1
  end

  test "it has a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@members_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{members_path(@project.slug)}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@members_decorator.new_link)
    assert_nil @node
  end
end
