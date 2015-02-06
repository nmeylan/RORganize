require 'test_helper'

class IssuesStatusesDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({issues_statuses: {current_page: 1}})

    @issues_statuses_decorator = IssuesStatus.all.decorate
  end

  test "it displays no data when collection is empty" do
    IssuesStatus.delete_all
    node(@issues_statuses_decorator.display_collection)
    assert_select '#issues-statuses-content', 1
    assert_select 'h3', I18n.t(:text_no_data)
  end

  test "it displays a table when collection contains entries" do
    @node = node @issues_statuses_decorator.display_collection
    assert_select '#issues-statuses-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@issues_statuses_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{issues_statuses_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@issues_statuses_decorator.new_link)
    assert_nil @node
  end
end
