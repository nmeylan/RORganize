require 'test_helper'

class QueriesDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    Query.create!(author_id: User.current.id, project_id: @project.id,
                  stringify_query: 'aaa', stringify_params: 'params',
                  object_type: 'Issue', name: 'my query')

    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)
    helpers.stubs(:session).returns({queries: {current_page: 1}})

    @queries_decorator = Query.all.decorate(context: {queries_url: queries_path, action_name: 'index'})
  end

  test "it displays no data when collection is empty" do
    @queries_decorator = Query.where('1=2').decorate(context: {queries_url: queries_path, action_name: 'index'})
    node(@queries_decorator.display_collection)
    assert_select '#queries-content', 1
    assert_select 'h3', I18n.t(:text_no_data)
  end

  test "it displays a table when collection contains entries" do
    node(@queries_decorator.display_collection)
    assert_select '#queries-content', 1
    assert_select 'table', 1
  end

  test "it override default pagination path" do
    assert_equal queries_path, @queries_decorator.pagination_path
  end

  test "it override default sortable action" do
    assert_equal 'index', @queries_decorator.sortable_action
  end
end
