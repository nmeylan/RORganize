require 'test_helper'

class CategoryDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @category_decorator = Category.create(name: 'Test category', project_id: @project.id).decorate
  end

  test "it has a link to edit when user is allowed to perform action" do
    allow_user_to('edit')
    node(@category_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_category_path(@project.slug, @category_decorator.id)
  end

  test "it has a link to delete when user is allowed to perform action" do
    allow_user_to('destroy')
    node(@category_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', category_path(@project.slug, @category_decorator.id)
  end

  test "it should not have a link to edit action when user is not allowed to perform action" do
    node(@category_decorator.edit_link)
    assert_select 'span', 1
    assert_select 'span', text: 'Test category'
  end

  test "it should not have a link to delete action when user is not allowed to perform action" do
    node(@category_decorator.delete_link)
    assert_nil @node
  end
end
