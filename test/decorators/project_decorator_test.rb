require 'test_helper'

class ProjectDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @project = projects(:projects_001)
    @project_decorator = @project.decorate
  end

  test "it displays a link to delete issue attachment when user is allowed to" do
    allow_user_to('update_project_informations', 'settings')
    attachment = Attachment.new(attachable_type: 'Project', attachable_id: 666, id: 666)
    node(@project_decorator.delete_attachment_link(attachment))
    assert_select 'a', 1
    assert_select 'a[href=?]', delete_attachment_project_settings_path(@project.slug, attachment)
  end

  test "it should not display a link to delete issue attachment when user is not allowed to" do
    attachment = Attachment.new(attachable_type: 'Project', attachable_id: 666, id: 666)
    assert_nil @project_decorator.delete_attachment_link(attachment)
  end

  test "it displays the latest project activity when it exists" do
    journal = Journal.new(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                          project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 20), user_id: User.current.id)
    Time.stubs(:now).returns(Time.new(2012, 10, 21))
    @project.stubs(:latest_activity).returns(journal)
    latest_activity_info = @project_decorator.latest_activity_info
    assert latest_activity_info.include?(I18n.t(:text_latest_activity))
    assert latest_activity_info.include?('1 day ago'), "<#{latest_activity_info}> doesn't contains : \"1 day ago\""
    assert latest_activity_info.include?('by Nicolas Meylan'), "<#{latest_activity_info}> doesn't contains : \"by Nicolas Meylan\""
  end

  test "it displays the latest project activity when it exists even with Unknown user" do
    journal = Journal.new(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                          project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 20))
    Time.stubs(:now).returns(Time.new(2012, 10, 21))
    @project.stubs(:latest_activity).returns(journal)
    latest_activity_info = @project_decorator.latest_activity_info
    assert latest_activity_info.include?(I18n.t(:text_latest_activity))
    assert latest_activity_info.include?('1 day ago'), "<#{latest_activity_info}> doesn't contains : \"1 day ago\""
    assert latest_activity_info.include?('by Unknown'), "<#{latest_activity_info}> doesn't contains : \"by Unknown\""
  end

  test "it displays all members of the project" do
    stub_project_members
    node(@project_decorator.display_members)
    assert_select 'div.members-block', 2
    assert_select 'h4.badge.badge-role', 2
    assert_select 'h4.badge.badge-role', text: 'Project Manager'
    assert_select 'h4.badge.badge-role', text: 'Team Member'
    assert_select 'a', 3
    assert_select 'a', text: 'Nicolas Meylan'
    assert_select 'a', text: 'James Bond'
    assert_select 'a', text: 'Roger Smith'
  end

  test "it do not display an overview of current project versions when project do not contains running versions" do
    @project.versions.clear
    node(@project_decorator.display_version_overview)
    assert_select 'h3', I18n.t(:text_no_versions)
  end

  test "it displays an overview of current project versions with default statistics when version is empty" do
    Date.stubs(:today).returns(Date.new(2012, 12, 02))
    @project.versions.clear
    @project.save
    version = Version.create!(name: 'New version', description: '', start_date: Date.new(2012, 12, 01), project_id: @project.id, is_done: false)
    node(@project_decorator.display_version_overview)
    assert_select 'h1', 1
    assert_select 'h1', 'New version'
    assert_select '.version-dates-header', 1
    assert_select '.version-dates-header', text: "2012-12-01-#{I18n.t(:text_no_due_date)}"
    assert_select '.requests-stats', text: "0 #{I18n.t(:label_request_plural)}, 0 #{I18n.t(:label_closed)}, 0 #{I18n.t(:label_opened)}."
    assert_select '.progress-bar', text: '0%'
  end

  test "it displays an overview of current project versions with statistics for issues" do
    Date.stubs(:today).returns(Date.new(2012, 12, 02))
    @project.versions.clear
    @project.save
    version = Version.create!(name: 'New version', description: '', start_date: Date.new(2012, 12, 01),
                              target_date: Date.new(2012, 12, 31), project_id: @project.id, is_done: false)
    Issue.create!(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '3', done: 40, project_id: @project.id, version_id: version.id)
    node(@project_decorator.display_version_overview)
    assert_select 'h1', 1
    assert_select 'h1', 'New version'
    assert_select '.version-dates-header', 1
    assert_select '.version-dates-header', text: "2012-12-01-2012-12-31"
    assert_select '.requests-stats', text: "1 #{I18n.t(:label_request_plural)}, 1 #{I18n.t(:label_closed)}, 0 #{I18n.t(:label_opened)}."
    assert_select '.progress-bar', text: '40%'
  end

  test "it displays a warning when a version is over ran" do
    Date.stubs(:today).returns(Date.new(2013, 01, 02))
    @project.versions.clear
    @project.save
    version = Version.create!(name: 'New version', description: '', start_date: Date.new(2012, 12, 01),
                              target_date: Date.new(2012, 12, 31), project_id: @project.id, is_done: false)
    node(@project_decorator.display_version_overview)
    assert_select 'h1', 1
    assert_select 'h1', 'New version'
    assert_select '.version-dates-header', 1
    assert_select '.version-dates-header', text: "2012-12-01-2012-12-31"
    assert_select '.over-run', text: %Q(#{t(:text_past_due)} #{t(:label_by)} 2 #{t(:label_plural_day)})
  end

  test "it displays a roadmap of the project with the current versions" do
    Date.stubs(:today).returns(Date.new(2012, 12, 04))
    @project.versions.clear
    @project.save
    version = Version.create!(name: 'New version', description: '', start_date: Date.new(2012, 12, 01), project_id: @project.id, is_done: false)
    version1 = Version.create!(name: 'Empty version', description: 'Definition of done', start_date: Date.new(2012, 12, 03), project_id: @project.id, is_done: false)
    issue = Issue.create!(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '3', done: 40, project_id: @project.id, version_id: version.id)
    node(@project_decorator.display_roadmap(@project.current_versions.decorate))
    assert_select 'h1', 2
    assert_select 'h1', 'New version'
    assert_select 'h1', 'Empty version'
    assert_select '.version-dates-header', 2
    assert_select '.version-dates-header', text: "2012-12-01-#{I18n.t(:text_no_due_date)}"
    assert_select '.version-dates-header', text: "2012-12-03-#{I18n.t(:text_no_due_date)}"
    assert_select '.requests-stats', text: "1 #{I18n.t(:label_request_plural)}, 1 #{I18n.t(:label_closed)}, 0 #{I18n.t(:label_opened)}."
    assert_select '.requests-stats', text: "0 #{I18n.t(:label_request_plural)}, 0 #{I18n.t(:label_closed)}, 0 #{I18n.t(:label_opened)}."
    assert_select '.progress-bar', text: '0%'
    assert_select '.progress-bar', text: '40%'

    assert_select '.box', 1
    assert_select '.box', text: 'Definition of done'

    assert_select 'fieldset', 1
    assert_select 'li a', text: "Task ##{issue.sequence_id} : #{issue.caption}"
  end

  private
  def stub_project_members
    project_manager = roles(:roles_001)
    team_member = roles(:roles_002)
    non_member = Role.non_member
    members = []
    members << Member.create(user_id: users(:users_001).id, project_id: @project.id, role_id: project_manager.id)
    members << Member.create(user_id: users(:users_002).id, project_id: @project.id, role_id: project_manager.id)
    members << Member.create(user_id: users(:users_003).id, project_id: @project.id, role_id: team_member.id)
    members << Member.create(user_id: users(:users_004).id, project_id: @project.id, role_id: non_member.id)
    @project.stubs(:members).returns(members)
  end
end
