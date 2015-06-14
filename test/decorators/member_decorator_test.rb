require 'test_helper'

class MemberDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @member_decorator = User.current.member_for(@project.id).decorate(context: {project: @project})
  end

  test "it display a role select box with the current member role selected when user is allowed to member change role" do
    allow_user_to('change_role')
    node(@member_decorator.role_selection(Role.all))
    assert_select 'select', 1
    assert_select 'select[data-link=?]', change_role_project_members_path(@project.slug, @member_decorator)
    assert_select 'option[selected]', text: @member_decorator.role.caption
  end

  test "it display role name when user is allowed to member change role" do
    assert_equal @member_decorator.role.caption, @member_decorator.role_selection(Role.all)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@member_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', project_member_path(@project.slug, @member_decorator)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @member_decorator.delete_link
  end
end
