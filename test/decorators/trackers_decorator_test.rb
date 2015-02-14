require 'test_helper'

class TrackersDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({trackers: {current_page: 1}})

    @trackers_decorator = Tracker.all.decorate(context: {checked_ids: [1]})
  end

  test "it displays no data when collection is empty" do
    Tracker.delete_all
    node(@trackers_decorator.display_collection)
    assert_select '#trackers-content', 1
    assert_select 'h3', I18n.t(:text_no_data)
  end

  test "it displays a table when collection contains entries" do
    @node = node @trackers_decorator.display_collection
    assert_select '#trackers-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@trackers_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{trackers_path}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@trackers_decorator.new_link)
    assert_nil @node
  end

  test "it displays checkbox to select which tracker to use in the project" do
    node(@trackers_decorator.settings_list)
    assert_select 'input[name=?]', '[trackers][Bug]'
    assert_select 'input[name=?]', '[trackers][Task]'
  end
end
