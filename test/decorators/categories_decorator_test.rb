require 'test_helper'

class CategoriesDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.stubs(:session).returns({categories: {current_page: 1}})

    @project = projects(:projects_001)
    @categories_decorator = @project.categories.decorate(context: {project: @project})
  end

  test "it displays no data when collection is empty" do
    @categories_decorator.clear
    node(@categories_decorator.display_collection)
    assert_select '#categories-content', 1
    assert_select 'h3', I18n.t(:text_no_categories)
  end

  test "it displays a table when collection contains entries" do
    @project.categories << Category.new(name: 'Category Test')
    @project.save
    @categories_decorator = @project.categories.decorate(context: {project: @project})
    @node = node @categories_decorator.display_collection
    assert_select '#categories-content', 1
    assert_select 'table', 1
  end

  test "it displays a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@categories_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{categories_path(@project.slug)}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@categories_decorator.new_link)
    assert_nil @node
  end
end
