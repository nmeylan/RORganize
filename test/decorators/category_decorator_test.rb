require 'test_helper'

class CategoryDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @category_decorator = Category.create(name: 'Test category', project_id: @project.id).decorate
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@category_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_project_category_path(@project.slug, @category_decorator)
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@category_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', project_category_path(@project.slug, @category_decorator)
  end

  test "it should not have a link to edit action when user is not allowed to" do
    node(@category_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'Test category'
  end

  test "it should not have a link to delete action when user is not allowed to" do
    node(@category_decorator.delete_link)
    assert_nil @node
  end
end
