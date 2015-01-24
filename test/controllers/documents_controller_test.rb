require 'test_helper'
require 'test_utilities/record_not_found_tests'

class DocumentsControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @document = Document.create(name: 'My document', project_id: @project.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of documents" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:documents_decorator)
  end

  test "should access to new document" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:document_decorator)
  end

  test "should create document" do
    assert_difference('Document.count') do
      post_with_permission :create, document: {name: 'New document', project_id: @project.id}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:document_decorator)
    assert_redirected_to document_path(@project.slug, assigns(:document_decorator).id)
  end

  test "should refresh the page when create document failed" do
    assert_no_difference('Document.count') do
      post_with_permission :create, document: {name: '', project_id: @project.id}
    end
    assert_not_nil assigns(:document_decorator)
    assert_response :unprocessable_entity
  end

  test "should edit document" do
    get_with_permission :edit, id: @document
    assert_response :success
    assert_not_nil assigns(:document_decorator)
  end

  test "should update document" do
    patch_with_permission :update, id: @document, document: {name: 'Change document name'}
    assert_not_empty flash[:notice]
    assert_redirected_to document_path(@project.slug, assigns(:document_decorator).id)
  end

  test "should view document" do
    get_with_permission :show, id: @document
    assert_response :success
    assert_not_nil assigns(:document_decorator)
  end

  test "should refresh the page when update category failed" do
    patch_with_permission :update, id: @document, document: {name: ''}
    assert_not_nil assigns(:document_decorator)
    assert_response :unprocessable_entity
  end

  test "should destroy document" do
    assert_difference('Document.count', -1) do
      delete_with_permission :destroy, id: @document, format: :js
    end
    assert_response :success
  end

  test "should get toolbox for documents" do
    get_with_permission :toolbox, ids: [@document.id], format: :js

    assert_response :success
    assert_template "js_templates/toolbox"
  end

  test "should edit documents with toolbox" do
    assert_nil @document.category_id
    get_with_permission :index
    post_with_permission :toolbox, ids: [@document.id], value: {category_id: "1", version_id: ""},format: :js
    @document.reload
    assert_equal 1, @document.category_id
    assert_response :success
    assert_template "index"
  end

  test "should delete documents with toolbox" do
    get_with_permission :index
    post_with_permission :toolbox, delete_ids: [@document.id],format: :js
    assert_raise(ActiveRecord::RecordNotFound) { @document.reload }
    assert_response :success
    assert_template "index"
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of documents" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new document" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create document" do
    should_get_403_on(:_post, :create, id: @document.id)
  end

  test "should get a 403 error when user is not allowed to edit document" do
    should_get_403_on(:_get, :edit, id: @document.id)
  end

  test "should get a 403 error when user is not allowed to view document" do
    should_get_403_on(:_get, :show, id: @document.id)
  end

  test "should get a 403 error when user is not allowed to update document" do
    should_get_403_on(:_patch, :update, id: @document.id)
  end

  test "should get a 403 error when user is not allowed to destroy document" do
    should_get_403_on(:_delete, :destroy, id: @document.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to get toolbox document" do
    should_get_403_on(:_get, :toolbox, ids: [@document.id], format: :js)
  end

  test "should get a 403 error when user is not allowed to post toolbox document" do
    should_get_403_on(:_post, :toolbox, ids: [@document.id], format: :js)
  end
end
