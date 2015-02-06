require 'test_helper'

class DocumentsDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)

    helpers.instance_eval('view_context').stubs(:sortable).returns('')
    helpers.instance_eval('view_context').instance_variable_set(:@project, @project)
    helpers.stubs(:session).returns({documents: {current_page: 1}})

    @documents_decorator = @project.documents.decorate(context: {project: @project})
    @controller.instance_variable_set(:@project, @project)
  end

  test "it displays no data when collection is empty" do
    @project.documents.clear
    node(@documents_decorator.display_collection)
    assert_select '#documents-content', 1
    assert_select 'h3', I18n.t(:text_no_documents)
  end

  test "it displays a table when collection contains entries" do
    @project.documents << Document.new(name: 'Test document', project_id: @project.id)
    @project.save
    @documents_decorator = @project.documents.decorate(context: {project: @project})
    node(@documents_decorator.display_collection)
    assert_select '#documents-content', 1
    assert_select 'table', 1
  end

  test "it has a link to new action when user is allowed to" do
    allow_user_to('new')
    node(@documents_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', "#{documents_path(@project.slug)}/new"
  end

  test "it should not have a link to new action when user is not allowed to" do
    node(@documents_decorator.new_link)
    assert_nil @node
  end
end
