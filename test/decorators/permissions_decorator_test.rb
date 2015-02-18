require 'test_helper'

class PermissionsDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @role = roles(:roles_001)

    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({permissions: {current_page: 1}})

    permissions = Permission.all
    group = Rorganize::Managers::PermissionManager::ControllerGroup.new(:misc, I18n.t(:label_misc), '', permissions.collect(&:controller))
    @permissions_decorator = permissions.decorate(context: {role_name: @role.caption,
                                                            controller_list: {group => permissions.collect(&:controller)}})
  end

  test "it displays a table when collection contains entries" do
    @controller.request.path_parameters[:role_name] = @role.caption
    @node = node @permissions_decorator.display_collection
    assert_select 'form', 1
    assert_select '#misc-tab', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@permissions_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{permissions_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@permissions_decorator.new_link)
    assert_nil @node
  end
end
