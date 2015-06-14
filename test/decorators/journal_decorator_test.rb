require 'test_helper'

class JournalDecoratorTest < Rorganize::Decorator::TestCase
  set_controller_class(ProjectsController)
  def setup
    @project = projects(:projects_001)
    create_journal_context
  end

  test "it displays the action type" do
    assert_equal I18n.t(:label_created_lower_case), @journal_creation_decorator.display_action_type
    assert_equal I18n.t(:label_updated_lower_case), @journal_update_decorator.display_action_type
    assert_equal I18n.t(:label_deleted_lower_case), @journal_deletion_decorator.display_action_type
  end

  test "it displays journalizable object type with its own method" do
    node(concat @journal_update_decorator.display_object_type)
    assert_select 'a', 1
    assert_select 'a[href=?]', project_issue_path(@project.slug, @issue)
    assert_select 'b', 1
    assert_select 'b', "#{I18n.t(:label_issue)} ##{@issue.sequence_id}".downcase
  end

  test "it display journalizable readable object type" do
    @journal_update_decorator.journalizable_type = 'Object'
    @journal_update_decorator.stubs(:journalizable).returns(nil)
    node(@journal_update_decorator.display_object_type)
    assert_select 'b', 1
    assert_select 'b', text: "object #{@issue.caption}"
  end

  test "it display journalizable readable complex object type" do
    @journal_update_decorator.journalizable_type = 'PascalCase'
    @journal_update_decorator.stubs(:journalizable).returns(nil)
    node(@journal_update_decorator.display_object_type)
    assert_select 'b', 1
    assert_select 'b', text: "pascal case #{@issue.caption}"
  end

  test "it displays a link to the project" do
    node(@journal_update_decorator.project_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', overview_projects_path(@project.slug)
  end

  test "it has a method to check if user avatar can be displayed" do
    assert @journal_update_decorator.user_avatar?
    @journal_update.user = nil
    assert_not @journal_update_decorator.user_avatar?
  end

  test "it displays the details when an element has been updated" do
    node(concat @journal_update_decorator.render_details)
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'ul' do
      assert_select 'li', 1
    end
  end

  test "it displays the details when an issue has been created" do
    node(concat @journal_creation_decorator.render_details)
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'body', text: "#{User.current.caption}#{I18n.t(:text_created_this_issue)}"
  end

  test "it displays the details when an element has been created" do
    @journal_creation_decorator.journalizable_type = 'Document'
    node(concat @journal_creation_decorator.render_details)
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'body', text: "#{User.current.caption}#{I18n.t(:text_created_this)} document"
  end

  test "it check if there are update details to render" do
    assert_not @journal_deletion_decorator.render_update_detail?
    assert_not @journal_creation_decorator.render_update_detail?
    assert @journal_update_decorator.render_update_detail?

    @journal_update_decorator.details.clear
    assert_not @journal_update_decorator.render_update_detail?
  end

  test "it check if there are creation details to render" do
    assert_not @journal_deletion_decorator.render_create_detail?
    assert_not @journal_update_decorator.render_create_detail?
    assert @journal_creation_decorator.render_create_detail?
  end

  test "it displays a specific icon for a each action type" do
    assert @journal_creation_decorator.display_action_type_icon.include?('octicon-plus')
    assert @journal_update_decorator.display_action_type_icon.include?('octicon-pencil')
    assert @journal_deletion_decorator.display_action_type_icon.include?('octicon-trashcan')
  end

  test "it displays a formatted created at" do
    assert_equal '12:30PM', @journal_creation_decorator.display_creation_at
    assert_equal '02:30PM', @journal_update_decorator.display_creation_at
    assert_equal '03:17PM', @journal_deletion_decorator.display_creation_at
  end

  test "it has a method to display author name without avatar" do
    node(@journal_update_decorator.display_author(false))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'img', 0
  end

  test "it has a method to display author name with avatar" do
    node(@journal_update_decorator.display_author(true))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'img', 1
  end

  test "it should not display author name when author does not exists anymore" do
    @journal_update_decorator.user = nil
    assert_equal I18n.t(:label_unknown), @journal_update_decorator.display_author(true)
  end

  private
  def create_journal_context
    @issue = issues(:issues_001)
    @journal_creation = Journal.create!(journalizable_type: 'Issue', journalizable_id: @issue.id, action_type: 'created', user_id: User.current.id,
                                        project_id: @project.id, journalizable_identifier: @issue.caption, created_at: Time.new(2012, 10, 20, 12, 30))
    @journal_update = Journal.create!(journalizable_type: 'Issue', journalizable_id: @issue.id, action_type: 'updated', user_id: User.current.id,
                                      project_id: @project.id, journalizable_identifier: @issue.caption, created_at: Time.new(2012, 10, 20, 14, 30))
    @journal_detail = JournalDetail.create!(journal_id: @journal_update.id, property: 'Status', property_key: :status_id,
                                            old_value: 'New', value: 'In Progress')
    @journal_deletion = Journal.create!(journalizable_type: 'Issue', journalizable_id: @issue.id, action_type: 'deleted', user_id: User.current.id,
                                        project_id: @project.id, journalizable_identifier: @issue.caption, created_at: Time.new(2012, 10, 20, 15, 17))

    @journal_creation_decorator = @journal_creation.decorate(context: {project: @project})
    @journal_update_decorator = @journal_update.decorate(context: {project: @project})
    @journal_deletion_decorator = @journal_deletion.decorate(context: {project: @project})
  end
end
