require 'test_helper'

class WikiControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @wiki = @project.build_wiki
    @wiki.save
    @wiki_page1= WikiPage.create(title: 'Page1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    @wiki_page2= WikiPage.create(title: 'Page2', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of the wiki" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:wiki_decorator)
  end

  test "should create a wiki" do
    @wiki.destroy
    assert_difference('Wiki.count') do
      post_with_permission :create
    end
    assert_not_empty flash[:notice]
    assert_redirected_to project_wiki_index_path(@project.slug)
  end

  test  "should get an error user create a and a wiki already exists" do
    assert_no_difference('Wiki.count') do
      post_with_permission :create
    end
    assert_redirected_to project_wiki_index_path(@project.slug)
  end

  test "should view all wiki pages" do
    get_with_permission :pages
    assert_response :success
  end

  test "should access to page organization" do
    allow_user_to('set_organization')
    get_with_permission :organize_pages
    assert_response :success
  end

  test "should set page organization" do
    assert_nil @wiki_page2.parent_id
    post_with_permission :set_organization, format: :js, pages_organization: {
                                              @wiki_page1.id.to_s => {parent_id: "null", position: "0"},
                                              @wiki_page2.id.to_s => {parent_id: @wiki_page1.id, "position" => "0"}}
    @wiki_page2.reload
    assert_equal @wiki_page1.id, @wiki_page2.parent_id
    assert_not_empty @response['flash-message']
  end

  # Forbidden actions
  test "should get a 403 error when user is not allowed to access to index of the wiki" do
    should_get_403_on(:_post, :index)
  end

  test "should get a 403 error when user is not allowed to access to create a wiki" do
    @wiki.destroy
    should_get_403_on(:_post, :create)
  end

  test "should get a 403 error when user is not allowed to access to wiki pages" do
    should_get_403_on(:_get, :pages)
  end

  test "should get a 403 error when user is not allowed to access to wiki page organization" do
    should_get_403_on(:_get, :organize_pages)
  end

  test "should get a 403 error when user is not allowed to access to wiki set page organization" do
    should_get_403_on(:_post, :set_organization,format: :js, pages_organization: {
                               @wiki_page1.id.to_s => {parent_id: "null", position: "0"},
                               @wiki_page2.id.to_s => {parent_id: @wiki_page1.id, "position" => "0"}})
  end
end
