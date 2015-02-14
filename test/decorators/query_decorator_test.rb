require 'test_helper'

class QueryDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @query_decorator = Query.create!(author_id: User.current.id, project_id: @project.id,
                                        stringify_query: 'aaa', stringify_params: 'params',
                                        object_type: 'Issue', name: 'my query').decorate

  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit', 'queries')
    node(@query_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_query_path(@query_decorator.id)
  end

  test "it displays a link to view query when user is allowed to" do
    allow_user_to('show', 'queries')
    node(@query_decorator.show_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', query_path(@query_decorator.id)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@query_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', query_path(@query_decorator.id)
  end

  test "it displays the user name" do
    assert_equal 'Nicolas Meylan', @query_decorator.author
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@query_decorator.edit_link)
  end

  test "it should just display the caption of the query when user is not allowed to view it" do
    assert_equal 'my query', @query_decorator.show_link
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@query_decorator.delete_link)
    assert_nil @node
  end
end
