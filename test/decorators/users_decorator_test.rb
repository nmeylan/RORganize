require 'test_helper'

class UsersDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({users: {current_page: 1}})

    @users_decorator = User.all.decorate
  end

  test "it displays no data when collection is empty" do
    User.delete_all
    node(@users_decorator.display_collection)
    assert_select '#users-content', 1
    assert_select 'h3', I18n.t(:text_no_data)
  end

  test "it displays a table when collection contains entries" do
    @node = node @users_decorator.display_collection
    assert_select '#users-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@users_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{users_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@users_decorator.new_link)
    assert_nil @node
  end
end
