require 'test_helper'
require 'test_utilities/record_not_found_tests'

class WikiPagesControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @wiki = @project.build_wiki
    @wiki.save
    @wiki_page = WikiPage.create(title: 'Page1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to new page form" do
    get_with_permission :new

    assert_response :success
    assert_not_nil assigns(:wiki_page_decorator)
    assert_template 'wiki_pages/new'
  end

  test "should access to new home page form" do
    allow_user_to('new')
    get_with_permission :new_home_page

    assert_response :success
    assert_not_nil assigns(:wiki_page_decorator)
    assert_template 'wiki_pages/new_home_page'
  end

  test "should access to new sub page form" do
    allow_user_to('new')
    get_with_permission :new_sub_page, id: @wiki_page

    assert_response :success
    assert_not_nil assigns(:wiki_page_decorator)
    assert_template 'wiki_pages/new_sub_page'
  end

  test "should create a new page" do
    assert_difference('WikiPage.count') do
      post_with_permission :create, wiki_page: {title: 'Test page'}
    end
    assert_redirected_to wiki_page_path(@project.slug, assigns(:wiki_page_decorator).slug)
  end

  test "should refresh the page when creation failed" do
    assert_no_difference('WikiPage.count') do
      post_with_permission :create, wiki_page: {title: ''}
    end
    assert_not_nil assigns(:wiki_page_decorator)
    assert_response :unprocessable_entity
  end

  test "should create a home new page" do
    assert_nil @wiki.home_page
    assert_difference('WikiPage.count') do
      post_with_permission :create, wiki_page: {title: 'Test page'}, wiki: {home_page: "true"}
    end
    @wiki.reload
    wiki_page = assigns(:wiki_page_decorator)
    assert_equal wiki_page, @wiki.home_page
    assert_redirected_to wiki_page_path(@project.slug, wiki_page.slug)
  end

  test "should create a sub page" do
    assert_empty @wiki_page.sub_pages
    assert_difference('WikiPage.count') do
      post_with_permission :create, wiki_page: {title: 'Test page', parent_id: @wiki_page.slug}
    end
    @wiki_page.reload
    wiki_page = assigns(:wiki_page_decorator)
    assert_equal @wiki_page, wiki_page.parent
    assert_redirected_to wiki_page_path(@project.slug, wiki_page.slug)
  end

  test "should not create sub page for a foreign wiki page" do
    other_project = projects(:projects_002)
    other_wiki = other_project.build_wiki
    other_wiki.save
    other_wiki_page = WikiPage.create(title: 'Page1', author_id: User.current.id, content: 'content', wiki_id: other_wiki.id)

    assert_difference('WikiPage.count') do
      post_with_permission :create, wiki_page: {title: 'Test page', parent_id: other_wiki_page.slug}
    end
    wiki_page = assigns(:wiki_page_decorator)
    assert_nil wiki_page.parent
    assert_redirected_to wiki_page_path(@project.slug, wiki_page.slug)
  end

  test "should edit wiki page" do
    get_with_permission :edit, id: @wiki_page.slug
    assert_response :success
    assert_not_nil assigns(:wiki_page_decorator)
  end

  test "should update wiki page" do
    patch_with_permission :update, id: @wiki_page.slug, wiki_page: {title: 'change title', content: 'add content'}
    assert_not_empty flash[:notice]
    assert_redirected_to wiki_page_path(@project.slug, @wiki_page.slug)
  end

  test "should view wiki page" do
    get_with_permission :show, id: @wiki_page.slug
    assert_response :success
    assert_not_nil assigns(:wiki_page_decorator)
  end

  test "should refresh the page when update wiki page failed" do
    patch_with_permission :update, id: @wiki_page.slug, wiki_page: {title: ''}
    assert_not_nil assigns(:wiki_page_decorator)
    assert_response :unprocessable_entity
  end

  test "should destroy wiki page" do
    assert_difference('WikiPage.count', -1) do
      delete_with_permission :destroy, id: @wiki_page.slug, format: :js
    end
    assert_response :success
  end

  # Forbidden action
  test "should get a 403 error when user is not allowed to access to new page form" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to access to new home page form" do
    should_get_403_on(:_get, :new_home_page)
  end

  test "should get a 403 error when user is not allowed to access to new sub page form" do
    should_get_403_on(:_get, :new_sub_page, id: @wiki_page)
  end

  test "should get a 403 error when user is not allowed to create a new page" do
    should_get_403_on(:_post, :create, wiki_page: {title: 'Test page'})
  end

  test "should get a 403 error when user is not allowed to edit page" do
    should_get_403_on(:_get, :edit, id: @wiki_page)
  end

  test "should get a 403 error when user is not allowed to view page" do
    should_get_403_on(:_get, :show, id: @wiki_page)
  end

  test "should get a 403 error when user is not allowed to update page" do
    should_get_403_on(:_patch, :update, id: @wiki_page)
  end

  test "should get a 403 error when user is not allowed to destroy page" do
    should_get_403_on(:_delete, :destroy, id: @wiki_page, format: :js)
  end
end
