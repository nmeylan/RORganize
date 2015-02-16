require 'test_helper'

class WikiDecoratorTest < Rorganize::Decorator::TestCase
  set_controller_class(WikiController)
  def setup
    @project = projects(:projects_001)
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)
    @wiki = Wiki.create!(project_id: @project.id)
    @wiki_decorator = @wiki.decorate(context: {project: @project})
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@wiki_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', wiki_path(@project.slug, @wiki.id)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @wiki_decorator.delete_link
  end

  test "it should not display a link to delete when wiki is a new record" do
    allow_user_to('destroy')
    @wiki.stubs(:new_record?).returns(true)
    assert_nil @wiki_decorator.delete_link
  end

  test "it displays a link to create a wiki when user is allowed to and wiki does not exists" do
    allow_user_to('new')
    @wiki.stubs(:new_record?).returns(true)
    node(concat @wiki_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', wiki_index_path(@project.slug)
    assert_select 'h2', text: I18n.t(:text_no_wiki)
  end

  test "it should not display a link to  create a wiki when user is not allowed to" do
    assert_nil @wiki_decorator.new_link
  end

  test "it should not display a link to create a wiki when wiki already exists" do
    assert_nil @wiki_decorator.new_link
  end

  test "it displays a link to organize pages when user is allowed to" do
    allow_user_to('set_organization')
    node(@wiki_decorator.organize_pages_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', organize_pages_wiki_index_path(@project.slug)
  end

  test "it should not display a link to organize pages when user is not allowed to" do
    assert_nil @wiki_decorator.organize_pages_link
  end

  test "it displays a link to create a new page when user is allowed to" do
    allow_user_to('new', 'wiki_pages')
    node(@wiki_decorator.new_page_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_wiki_page_path(@project.slug)
  end

  test "it should not display a link to create a new page when user is not allowed to" do
    assert_nil @wiki_decorator.new_page_link
  end

  test "it displays a home page if it exists" do
    @wiki.home_page = WikiPage.create!(title: 'Home page', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    node(concat @wiki_decorator.home_page)
    assert_select 'h1', 'Home page'
    assert_select 'p', 'content'
  end

  test "it displays a link to create new home page if it does not exists when user is allowed to" do
    allow_user_to('new', 'wiki_pages')
    node(concat @wiki_decorator.home_page)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_home_page_wiki_pages_path(@project.slug)
  end

  test "it displays a empty data message if it does not exists when user is allowed to" do
    node(concat @wiki_decorator.home_page)
    assert_select '.no-data', text: I18n.t(:text_empty_page)
  end

  test "it displays all page names into an index" do
    @wiki.pages << WikiPage.create!(title: 'Home page', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    @wiki.save
    node(concat @wiki_decorator.display_pages)
    assert_select 'ul', 1
    assert_select 'li', 1
  end

  test "it displays a no data message when there are no pages to display in the index" do
    node(concat @wiki_decorator.display_pages)
    assert_select '.no-data', text: I18n.t(:text_no_wiki_page)
  end
end
