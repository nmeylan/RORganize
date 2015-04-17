require 'test_helper'

class TrackerDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @tracker_decorator = trackers(:trackers_002).decorate
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@tracker_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_tracker_path(@tracker_decorator)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@tracker_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', tracker_path(@tracker_decorator)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@tracker_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'Bug'
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@tracker_decorator.delete_link)
    assert_nil @node
  end

  test "it displays a link to increment the tracker position" do
    assert_equal 2, @tracker_decorator.position
    node(@tracker_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to increment the tracker position when position is already the top" do
    @tracker_decorator.position = 1
    assert_equal 1, @tracker_decorator.position
    node(@tracker_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-up-arrow', 1
  end

  test "it displays a link to decrement the tracker position" do
    collection_size = IssuesStatus.all.count
    assert_not_equal collection_size, @tracker_decorator.position
    node(@tracker_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to decrement the tracker position when position is already the top" do
    collection_size = IssuesStatus.all.count
    @tracker_decorator.position = collection_size
    node(@tracker_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-down-arrow', 1
  end
end
