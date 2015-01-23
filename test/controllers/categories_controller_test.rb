require 'test_helper'
require 'test_utilities/record_not_found_tests'
class CategoriesControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @category = Category.create(name: 'My category', project_id: @project.id)
  end

  test "should get index" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:categories_decorator)
  end

  test "should get new" do
    get_with_permission :new
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post_with_permission :create, category: {name: 'New category'}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to categories_path(@project.slug)
  end

  test "should refresh the page when create category failed" do
    assert_no_difference('Category.count') do
      post_with_permission :create, category: {name: ''}
    end
    assert_not_nil assigns(:category)
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get_with_permission :edit, id: @category
    assert_response :success
  end

  test "should update category" do
    patch_with_permission :update, id: @category, category: {name: 'Change category name'}
    assert_not_empty flash[:notice]
    assert_redirected_to categories_path(@project.slug)
  end

  test "should refresh the page when update category failed" do
    patch_with_permission :update, id: @category, category: {name: ''}
    assert_not_nil assigns(:category)
    assert_response :unprocessable_entity
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete_with_permission :destroy, id: @category, format: :js
    end
    assert_response :success
  end

  # Action Forbidden
  test "should get a 403 error when user is allowed perform index" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is allowed perform new" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is allowed perform create category" do
    should_get_403_on(:_post, :create, id: @category.id)
  end

  test "should get a 403 error when user is allowed perform edit" do
    should_get_403_on(:_get, :edit, id: @category.id)
  end

  test "should get a 403 error when user is allowed perform update category" do
    should_get_403_on(:_patch, :update, id: @category.id)
  end

  test "should get a 403 error when user is allowed perform destroy category" do
    should_get_403_on(:_delete, :destroy, id: @category.id)
  end

end
