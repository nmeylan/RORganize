require 'test_helper'

class RoleDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @role_decorator = Role.create(name: 'Test role', is_locked: false).decorate
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@role_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_role_path(@role_decorator)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@role_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', role_path(@role_decorator)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@role_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'Test role'
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@role_decorator.delete_link)
    assert_nil @node
  end
end
