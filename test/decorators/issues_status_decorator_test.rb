require 'test_helper'

class IssuesStatusDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @status_decorator = issues_statuses(:issues_statuses_001).decorate
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@status_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_issues_status_path(@status_decorator.id)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@status_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', issues_status_path(@status_decorator.id)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@status_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'New'
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@status_decorator.delete_link)
    assert_nil @node
  end

  test "it displays a link to increment the status position" do
    assert_equal 7, @status_decorator.position
    node(@status_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to increment the status position when position is already the top" do
    @status_decorator.enumeration.position = 1
    assert_equal 1, @status_decorator.position
    node(@status_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-up-arrow', 1
  end

  test "it displays a link to decrement the status position" do
    collection_size = IssuesStatus.all.count
    assert_not_equal collection_size, @status_decorator.position
    node(@status_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to decrement the status position when position is already the top" do
    collection_size = IssuesStatus.all.count
    @status_decorator.enumeration.position = collection_size
    node(@status_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-down-arrow', 1
  end
end
