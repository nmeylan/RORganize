require 'test_helper'

class VersionDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @version_decorator = versions(:versions_003).decorate
  end
  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@version_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_version_path(@project.slug, @version_decorator)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@version_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', version_path(@project.slug, @version_decorator)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@version_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'Version 0.3'
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@version_decorator.delete_link)
    assert_nil @node
  end

  test "it displays a link to increment the version position" do
    assert_equal 4, @version_decorator.position
    node(@version_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to increment the version position when position is already the top" do
    @version_decorator.position = 1
    assert_equal 1, @version_decorator.position
    node(@version_decorator.inc_position_link)
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-up-arrow', 1
  end

  test "it displays a link to decrement the version position" do
    collection_size = IssuesStatus.all.count
    assert_not_equal collection_size, @version_decorator.position
    node(@version_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 1
  end

  test "it displays a disabled link to decrement the version position when position is already the top" do
    collection_size = IssuesStatus.all.count
    @version_decorator.position = collection_size
    node(@version_decorator.dec_position_link(collection_size))
    assert_select 'a', 1
    assert_select 'a.change-position', 0
    assert_select 'a.icon-disabled-down-arrow', 1
  end

  test "it displays the version description inside a box" do
    node(@version_decorator.display_description)
    assert_select '.box', 1
    assert_select '.box', text: "My awesome description"
  end

  test "it displays the version id" do
    assert_equal 4, @version_decorator.display_id
  end

  test "it displays a default version id when it is nil" do
    @version_decorator.id = nil
    assert_equal 'unplanned', @version_decorator.display_id
  end

  test "it displays a formatted target date" do
    @version_decorator.target_date = Date.new(2012, 12, 01)
    assert_equal Date.new(2012, 12, 01), @version_decorator.display_target_date
  end

  test "it displays a formatted start date" do
    @version_decorator.start_date = Date.new(2012, 12, 01)
    assert_equal Date.new(2012, 12, 01), @version_decorator.display_start_date
  end

  test "it displays a hyphen when start date is nil" do
    @version_decorator.start_date = nil
    assert_equal '-', @version_decorator.display_start_date
  end

  test 'it displays a no due date when target date is nil' do
    @version_decorator.target_date = nil
    assert_equal I18n.t(:text_no_due_date), @version_decorator.display_target_date
  end

  test 'it displays an indicator when version is done' do
    @version_decorator.is_done = true
    node(@version_decorator.display_is_done)
    assert_select 'strong', text: I18n.t(:text_done)
  end

  test 'it displays an indicator when version is not done' do
    @version_decorator.is_done = false
    node(@version_decorator.display_is_done)
    assert_select 'strong', text: I18n.t(:text_opened)
  end
end
