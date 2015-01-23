require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
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

  # Record not found
  test "should redirect to 404 when record is not found on edit" do
    should_get_404_on :get_with_permission, :edit, id: 666
  end

  test "should redirect to 404 when record is not found on update" do
    should_get_404_on :patch_with_permission, :update, id: 666, category: {name: 'Change category name'}
  end

  test "should redirect to 404 when record is not found on destroy" do
    should_get_404_on :delete_with_permission, :destroy, id: 666
  end

  # Action Forbidden
  test "should get a 403 error when user is allowed perform index" do
    _get :index
    assert_response :forbidden
  end

  test "should get a 403 error when user is allowed perform new" do
    _get :new
    assert_response :forbidden
  end

  test "should get a 403 error when user is allowed perform create category" do
    assert_no_difference('Category.count') do
      _post :create, category: {name: 'New category'}
    end
    assert_response :forbidden
  end

  test "should get a 403 error when user is allowed perform edit" do
    _get :edit, id: @category
    assert_response :forbidden
  end

  test "should get a 403 error when user is allowed perform update category" do
    _patch :update, id: @category, category: {name: 'Change category name'}
    assert_response :forbidden
  end

  test "should get a 403 error when user is allowed perform destroy category" do
    assert_no_difference('Category.count', -1) do
      _delete :destroy, id: @category, format: :js
    end
    assert_response :forbidden
  end

end
