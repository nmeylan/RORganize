require 'test_helper'

class QueriesControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @attributes = {name: "Parker Ferry issues", description: "", is_public: "0",
                   is_for_all: "0", object_type: "Issue"}
    @filters = {"assigned_to" => {"operator" => "equal", "value" => ["7"]}}
    @query = Query.create_query(@attributes, @project, @filters)
    @query.save
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of public and global queries" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:queries_decorator)
  end

  test "should access to new query form" do
    allow_user_to(:new)
    get_with_permission :new_project_query, query_type: 'Issue', format: :js
    assert_response :success
    assert_not_nil assigns(:query)
  end

  test "should get 404 on new query action when project is undefined" do
    allow_user_to(:new)
    should_get_404_on(:get_with_permission, :new_project_query, query_type: 'Issue', project_id: 'hello', format: :js)
  end

  test "should create query for issues" do
    params = query_params_hash('Issue')
    assert_difference('Query.count') do
      post_with_permission :create, params
    end
    assert_response :success
  end

  test "should create query for documents" do
    params = query_params_hash('Document')
    assert_difference('Query.count') do
      post_with_permission :create, params
    end
    assert_response :success
  end

  test "should get error message when creation fail" do
    params = query_params_hash('Issue', nil)
    assert_no_difference('Query.count') do
      post_with_permission :create, params
    end
    assert_response :unprocessable_entity
    assert_not_empty @response.header["flash-error-message"]
  end

  test "should view query" do
    get_with_permission :show, id: @query.id
    assert_response :success
    assert_not_nil assigns(:query_decorator)
  end

  test "should edit query filter" do
    assert_equal(original_query_filter, @query.stringify_params)
    put_with_permission :edit_query_filter, update_query_params_hash(@query.slug)

    @query.reload
    assert_equal("{\"status\"=>{\"operator\"=>\"equal\", \"value\"=>[\"1\", \"2\"]}}", @query.stringify_params)

    assert_response :success
    assert_not_empty @response.header["flash-message"]
  end

  test "should not edit query filter when missing params" do
    assert_equal(original_query_filter, @query.stringify_params)
    put_with_permission :edit_query_filter, update_query_missing_params_hash

    @query.reload
    assert_equal(original_query_filter, @query.stringify_params)

    assert_response :success
    assert_not_empty @response.header["flash-error-message"]
  end

  test "should get 404 on edit query with undefined query id" do
    assert_equal(original_query_filter, @query.stringify_params)
    put_with_permission :edit_query_filter, update_query_params_hash('undefined-query')

    @query.reload
    assert_equal(original_query_filter, @query.stringify_params)

    assert_response :missing
    assert_not_empty @response.header["flash-error-message"]
  end

  test "should edit query" do
    get_with_permission :edit, id: @query.id
    assert_response :success
    assert_not_nil assigns(:query)
  end

  test "should update query" do
    patch_with_permission :update, id: @query.id, query: {name: "Parker Ferry issues edited", description: "Edit description", is_public: "0",
                                                          is_for_all: "0", object_type: "Issue"}
    assert_not_empty flash[:notice]
    assert_redirected_to query_path(@query.id)
  end

  test "should refresh the page when update query failed" do
    patch_with_permission :update, id: @query.id, query: {name: "", description: "", is_public: "0", is_for_all: "0", object_type: "Issue"}
    assert_not_nil assigns(:query)
    assert_response :unprocessable_entity
  end

  test "should destroy query" do
    assert_difference('Query.count', -1) do
      delete_with_permission :destroy, id: @query.id, format: :js
    end
    assert_response :success
  end

  # Forbidden actions
  test "should get a 403 error when user is not allowed to access index of public queries" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to edit public query" do
    @query.update_attribute(:is_public, true)
    should_get_403_on(:_get, :edit, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to edit not owned query" do
    @query.update_attribute(:author_id, 666)
    should_get_403_on(:_get, :edit, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to view public query" do
    @query.update_attribute(:is_public, true)
    should_get_403_on(:_get, :show, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to view not owned query" do
    @query.update_attribute(:author_id, 666)
    should_get_403_on(:_get, :show, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to update public query" do
    @query.update_attribute(:is_public, true)
    should_get_403_on(:patch_with_permission, :update, id: @query.id, query: {name: "", description: "", is_public: "0", is_for_all: "0", object_type: "Issue"})
  end

  test "should get a 403 error when user is not allowed to update not owned query" do
    @query.update_attribute(:author_id, 666)
    should_get_403_on(:patch_with_permission, :update, id: @query.id, query: {name: "", description: "", is_public: "0", is_for_all: "0", object_type: "Issue"})
  end

  test "should get a 403 error when user is not allowed to destroy public query" do
    @query.update_attribute(:is_public, true)
    should_get_403_on(:_delete, :destroy, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to destroy not owned query" do
    @query.update_attribute(:author_id, 666)
    should_get_403_on(:_delete, :destroy, id: @query.id)
  end

  test "should get a 403 error when user is not allowed to edit filter of public query" do
    @query.update_attribute(:is_public, true)
    should_get_403_on(:_patch, :edit_query_filter, update_query_params_hash(@query.slug))
  end

  test "should get a 403 error when user is not allowed to view edit filter of not owned query" do
    @query.update_attribute(:author_id, 666)
    should_get_403_on(:_patch, :edit_query_filter, update_query_params_hash(@query.slug))
  end

  private
  def query_params_hash(type, name = 'Query test')
    {
        filters_list: ["status"],
        filter: {status: {operator: "equal", value: ["1"]}},
        query: {name: name, description: "", is_public: "0", is_for_all: "0", object_type: type},
        format: :js
    }
  end

  def update_query_params_hash(slug)
    {
        filters_list: ["status"],
        filter: {status: {operator: "equal", value: ["1", "2"]}},
        query_id: slug,
        format: :js
    }
  end

  def update_query_missing_params_hash
    {
        filters_list: ["status"],
        filter: {status: {operator: "equal", value: nil}},
        query_id: @query.slug,
        format: :js
    }
  end

  def original_query_filter
    "{\"assigned_to\"=>{\"operator\"=>\"equal\", \"value\"=>[\"7\"]}}"
  end
end
