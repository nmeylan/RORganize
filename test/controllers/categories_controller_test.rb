require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @category = Category.create(name: 'My category', project_id: @project.id)
  end

  test "should get index" do
    get :index, project_id: @project.slug
    assert_response :success
    assert_not_nil assigns(:categories_decorator)
  end

  test "should get new" do
    get :new, project_id: @project.slug
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, category: {name: 'New category'}, project_id: @project.slug
    end
    assert_not_empty flash[:notice]
    assert_redirected_to categories_path(@project.slug)
  end

  test "should refresh the page when create category failed" do
    assert_no_difference('Category.count') do
      post :create, category: {name: ''}, project_id: @project.slug
    end
    assert_not_nil assigns(:category)
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get :edit, id: @category, project_id: @project.slug
    assert_response :success
  end

  test "should redirect to 404 when record is not found on edit" do
    get :edit, id: 666, project_id: @project.slug
    assert_response :missing
  end

  test "should update category" do
    patch :update, id: @category, category: {name: 'Change category name'}, project_id: @project.slug
    assert_not_empty flash[:notice]
    assert_redirected_to categories_path(@project.slug)
  end

  test "should refresh the page when update category failed" do
    patch :update, id: @category, category: {name: ''}, project_id: @project.slug
    assert_not_nil assigns(:category)
    assert_response :unprocessable_entity
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, id: @category, project_id: @project.slug, format: :js
    end
    assert_response :success
  end

end
