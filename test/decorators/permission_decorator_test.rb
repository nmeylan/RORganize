require 'test_helper'

class PermissionDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @permission_decorator = Permission.create(action: 'new', controller: 'controller', name: 'New', is_locked: false).decorate
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@permission_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_permission_path(@permission_decorator.id)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@permission_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', permission_path(@permission_decorator.id)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    assert_equal 'New', @permission_decorator.edit_link
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@permission_decorator.delete_link)
    assert_nil @node
  end

  test "it should not have a link to delete action when permission is locked" do
    allow_user_to('destroy')
    @permission_decorator.is_locked = true
    node(concat @permission_decorator.delete_link)
    assert_select 'span.octicon-lock', 1
  end
end
