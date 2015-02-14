require 'test_helper'

class RolesDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({roles: {current_page: 1}})

    @roles_decorator = Role.all.decorate
  end

  test "it displays no data when collection is empty" do
    @roles_decorator = Role.where('1=2').decorate
    node(@roles_decorator.display_collection)
    assert_select '#roles-content', 1
    assert_select 'h3', I18n.t(:text_no_roles)
  end

  test "it displays a table when collection contains entries" do
    @node = node @roles_decorator.display_collection
    assert_select '#roles-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@roles_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{roles_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@roles_decorator.new_link)
    assert_nil @node
  end
end
