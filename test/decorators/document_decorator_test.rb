require 'test_helper'

require 'shared/history'

class DocumentDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    @document = Document.create(name: 'Test document', project_id: @project.id)
    @document_decorator = @document.decorate(context: {project: @project})
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@document_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_document_path(@project.slug, @document)
  end

  test "it should not display a link to edit when user is not allowed to" do
    assert_nil @document_decorator.edit_link
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@document_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', document_path(@project.slug, @document)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @document_decorator.delete_link
  end

  test "it displays a link to delete document attachment when user is allowed to" do
    allow_user_to('delete_attachment')
    attachment = Attachment.new(attachable_type: 'Document', attachable_id: 666, id: 666)
    node(@document_decorator.delete_attachment_link(attachment))
    assert_select 'a', 1
    assert_select 'a[href=?]', delete_attachment_documents_path(@project.slug, attachment)
  end

  test "it should not display a link to delete document attachment when user is not allowed to" do
    attachment = Attachment.new(attachable_type: 'Document', attachable_id: 666, id: 666)
    assert_nil @document_decorator.delete_attachment_link(attachment)
  end

  test "it displays a link to create a new document when user is allowed to" do
    allow_user_to('new')
    node(@document_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_document_path(@project.slug)
  end

  test "it should not display a link to create a new document when user is not allowed to" do
    assert_nil @document_decorator.new_link
  end

  test "it displays a link to the document for activity context" do
    node(concat @document_decorator.display_object_type(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', document_path(@project.slug, @document)
    assert_select 'b', 1
    assert_select 'b', "#{I18n.t(:label_document)}".downcase
  end

  test "it displays a link to watch a document when user is allowed" do
    allow_user_to('watch')
    node(@document_decorator.watch(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', toggle_watchers_path(@project.slug, 'Document', @document.id)
    assert_select 'a', text: I18n.t(:link_watch)
  end

  test "it displays a link to unwatch a document when user is allowed" do
    allow_user_to('watch')
    node(@document_decorator.unwatch(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', toggle_watchers_path(@project.slug, 'Document', @document.id)
    assert_select 'a', text: I18n.t(:link_unwatch)
  end

  test "it displays the history of the documents when it contains journals or comments" do
    # Add one journal
    @document.category = Category.create(name: 'Specs')
    @document.save
    history = History.new(Journal.journalizable_activities(@document_decorator.id, 'Document'), @document_decorator.comments)
    node(@document_decorator.display_history(history))
    assert_select '#history', 1
    assert_select 'h2', text: I18n.t(:label_history)
    assert_select '#history-blocks', 1
  end

  test "it should not display the history of the documents when it contains nothing" do
    history = History.new(Journal.journalizable_activities(@document_decorator.id, 'Document'), @document_decorator.comments)
    node(@document_decorator.display_history(history))
    assert_select '#history', 1
    assert_select 'h2', 0
    assert_select '#history-blocks', 0
  end

  test "user should be allowed to edit documents" do
    allow_user_to('edit')
    document = Document.create(name: 'Test document', project_id: @project.id)
    document_decorator = document.decorate(context: {project: @project})

    assert document_decorator.user_allowed_to_edit?
  end

  test "user should not be allowed to edit documents" do
    document = Document.create(name: 'Test document', project_id: @project.id)
    document_decorator = document.decorate(context: {project: @project})

    assert_not document_decorator.user_allowed_to_edit?
  end
end
