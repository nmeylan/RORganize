require 'test_helper'

class WikiPageDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)
    @wiki = Wiki.create!(project_id: @project.id)
    @wiki_page = WikiPage.create!(title: 'Home page', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    @wiki_page_decorator = @wiki_page.decorate(context: {project: @project})
  end


  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@wiki_page_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_project_wiki_page_path(@project.slug, @wiki_page.slug)
  end

  test "it should not display a link to edit when user is not allowed to" do
    assert_nil @wiki_page_decorator.edit_link
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@wiki_page_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', project_wiki_page_path(@project.slug, @wiki_page.slug)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @wiki_page_decorator.delete_link
  end

  test "it displays a link to create new sub page when user is allowed to create a new wiki page" do
    allow_user_to('new', 'wiki_pages')
    node(concat @wiki_page_decorator.new_subpage_link)
    assert_select 'a', 1
    assert_select 'a[href=?]',new_sub_page_project_wiki_pages_path(@project.slug, @wiki_page.slug)
  end

  test "it should not display a link to create new sub page when user is not allowed to" do
    assert_nil @wiki_page_decorator.new_subpage_link
  end

  test "it displays a breadcrumb even when wiki page has no parents" do
    node(concat @wiki_page_decorator.display_breadcrumb)
    assert_select 'a', 1
    assert_select 'a[href=?]', project_wiki_page_path(@project.slug, @wiki_page.slug)
    assert_select '.octicon-chevron-right', 0
  end

  test "it displays a breadcrumb when wiki page has parent" do
    parent_page = WikiPage.create!(title: 'Parent page', author_id: User.current.id, content: 'content parent page', wiki_id: @wiki.id)
    @wiki_page.parent = parent_page
    node(concat @wiki_page_decorator.display_breadcrumb)
    assert_select 'a', 2
    assert_select 'a[href=?]', project_wiki_page_path(@project.slug, @wiki_page.slug)
    assert_select 'a[href=?]', project_wiki_page_path(@project.slug, parent_page.slug)
    assert_select '.octicon-chevron-right', 1
  end

  test "it displays the list of all page parents" do
    grand_parent_page = WikiPage.create!(title: 'Grand parent page', author_id: User.current.id, content: 'content Grand parent page', wiki_id: @wiki.id)
    parent_page = WikiPage.create!(title: 'Parent page', author_id: User.current.id,
                                   content: 'content parent page', wiki_id: @wiki.id, parent_id: grand_parent_page.id)
    @wiki_page.parent = parent_page
    assert_equal [grand_parent_page, parent_page, @wiki_page], @wiki_page_decorator.parents
  end

  test "it displays author name" do
    assert_equal 'Nicolas Meylan', @wiki_page_decorator.author_name
  end

  test "it displays page content" do
    node(@wiki_page_decorator.display_page)
    assert_select 'p', text: 'content'
  end

  test "it displays a message when page content is empty" do
    @wiki_page.content = nil
    node(@wiki_page_decorator.display_page)
    assert_select '.no-data', text: I18n.t(:text_empty_page)
  end

  test "it displays a link to the page for activity context" do
    node(concat @wiki_page_decorator.display_object_type(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', project_wiki_page_path(@project.slug, @wiki_page.slug)
    assert_select 'b', 1
    assert_select 'b', "#{I18n.t(:label_wiki_page )}".downcase
  end
end
