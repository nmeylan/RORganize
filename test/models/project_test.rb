# Author: Nicolas Meylan
# Date: 24.06.14
# Encoding: UTF-8
# File: project_test.rb
require 'test_helper'
class ProjectTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.current = User.find_by_id(1)
    @project = Project.create(name: 'Rorganize test', is_public: true)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @project.destroy
  end

  test 'it should generate new slug when name change' do
    assert_equal 'rorganize-test', @project.slug

    @project.name = 'RORganize-test'
    @project.save
    @project.reload
    assert_equal 'rorganize-test', @project.slug

    @project.name = 'project-test'
    @project.save
    @project.reload
    assert_equal 'project-test', @project.slug
  end

  test 'caption should be equal to slug' do
    assert_equal 'rorganize-test', @project.slug
    assert_equal @project.slug, @project.caption
  end

  test 'it should contains at least the following journalizable items' do
    at_least_expectations = ['Issue', 'Document', 'Member', 'Version']
    actual = Project.journalizable_items
    at_least_expectations.each do |expectation|
      assert actual.include?(expectation)
    end
  end

  test 'it set created by on project creation' do
    assert_equal User.current, @project.author
  end

  test 'it set project author as member with project manager role' do
    author_member = Member.find_by_project_id_and_user_id(@project.id, @project.author)
    project_manager_role = Role.find_by_name('Project Manager')
    assert author_member
    assert_equal project_manager_role, author_member.role
  end

  test 'it enable default modules on project creation' do
    expectation = Rorganize::Managers::ModuleManager::enabled_by_default_modules
    expectation = expectation.collect { |mod| mod[:name] }
    assert_match_array expectation, @project.enabled_modules.collect(&:name)
  end

  test 'it can be starred by a user' do
    assert_not @project.starred?
    member = Member.find_by_project_id_and_user_id(@project.id, User.current)
    member.is_project_starred = true
    member.save
    @project.reload
    assert @project.starred?
  end

  test 'it has opened projects' do
    assert_match_array [1, 6, @project.id], Project.opened_projects_id
  end

  test "it load issues activities" do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                             project_id: @project.id, journalizable_identifier: 'issue1', created_at: Time.new(2012, 10, 20, 11, 1))
    journal1 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: @project.id, journalizable_identifier: 'issue2', created_at: Time.new(2012, 10, 21, 12, 1))
    journal2 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: @project.id, journalizable_identifier: 'issue3', created_at: Time.new(2012, 10, 22, 13, 1))
    journal3 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: @project.id, journalizable_identifier: 'issue4', created_at: Time.new(2012, 10, 23, 12, 1))

    expected = [journal, journal1, journal2, journal3]
    actual = @project.activities(['Issue'], :ONE_WEEK, Date.new(2012, 10, 23))
    assert_match_array expected, actual

    expected = [journal, journal1, journal2]
    actual = @project.activities(['Issue'], :THREE_DAYS, Date.new(2012, 10, 22))
    assert_match_array expected, actual
  end

  test 'it load document and issues comments' do
    date1 = Time.new(2001, 2, 2, 13, 30, 0)
    date2 = Time.new(2001, 2, 1, 14, 30, 0)
    date3 = Time.new(2001, 2, 3, 14, 30, 0)
    date4 = Time.new(2001, 2, 4, 14, 30, 0)
    date5 = Time.new(2001, 1, 31, 14, 30, 0)
    dates = []
    dates << date1 << date2 << date3 << date4 << date5
    issues_comments = []
    documents_comments = []
    issues_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date1})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date2})

    issues_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date3})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date4})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date5})

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array issues_comments,
                       @project.comments_for(['Issue'], period, range_end_date).to_a

    assert_match_array documents_comments[0, 1],
                       @project.comments_for(['Document'], period, range_end_date).to_a

    assert_match_array issues_comments + documents_comments[0, 1],
                       @project.comments_for(['Issue', 'Document'], period, range_end_date).to_a

    range_end_date = Date.new(2001, 2, 4)
    period = :ONE_WEEK
    assert_match_array issues_comments,
                       @project.comments_for(['Issue'], period, range_end_date).to_a

    assert_match_array documents_comments,
                       @project.comments_for(['Document'], period, range_end_date).to_a

    assert_match_array issues_comments + documents_comments,
                       @project.comments_for(['Issue', 'Document'], period, range_end_date).to_a
  end

  test 'it load latest activity' do
    last_activity = @project.latest_activity
    assert_equal 'Member', last_activity.journalizable_type
    assert_equal Journal::ACTION_CREATE, last_activity.action_type
  end

  test 'it load latest comment' do
    last_comment = @project.latest_comment
    assert_nil last_comment
    comment = Comment.create!(content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                              commentable_id: 666, commentable_type: 'Issue', created_at: Time.new(2012, 12, 01, 13, 50, 50))

    last_comment = @project.latest_comment
    assert_equal comment, last_comment

    comment1 = Comment.create!(content: 'this a second comment', user_id: User.current.id, project_id: @project.id,
                              commentable_id: 666, commentable_type: 'Issue', created_at: Time.new(2012, 12, 01, 13, 50, 53))
    last_comment = @project.latest_comment
    assert_equal comment1, last_comment
  end

  test 'it has active versions' do
    active_version = Version.new(name: 'version1', start_date: Date.new(2012, 12, 1), is_done: false)
    @project.versions << active_version
    @project.save
    assert_equal [active_version], @project.active_versions.to_a

    inactive_version = Version.new(name: 'version2', start_date: Date.new(2012, 11, 1), is_done: true)
    @project.versions << inactive_version
    @project.save
    assert_equal [active_version], @project.active_versions.to_a

    active_version1 = Version.new(name: 'version3', start_date: Date.new(2012, 11, 22), is_done: false)
    @project.versions << active_version1
    @project.save
    assert_equal [active_version, active_version1].reverse, @project.active_versions.to_a
  end

  test 'it has current versions' do
    version = Version.new(name: 'version1', start_date: Date.new(2012, 11, 1), is_done: false)
    version1 = Version.new(name: 'version2', start_date: Date.new(2012, 11, 21), is_done: false)
    version2 = Version.new(name: 'version3', start_date: Date.new(2012, 12, 1), is_done: false)
    @project.versions << version << version1 << version2
    @project.save
    Date.stubs(:today).returns(Date.new(2012, 11, 29))
    assert_match_array [version, version1], @project.current_versions.to_a

    Date.stubs(:today).returns(Date.new(2012, 12, 29))
    assert_match_array [version, version1, version2], @project.current_versions.to_a
  end

  test 'it has old versions' do
    version = Version.new(name: 'version1', start_date: Date.new(2012, 11, 1), is_done: true)
    version1 = Version.new(name: 'version2', start_date: Date.new(2012, 11, 21), is_done: false)
    version2 = Version.new(name: 'version3', start_date: Date.new(2012, 12, 1), is_done: true)
    @project.versions << version << version1 << version2
    @project.save
    Date.stubs(:today).returns(Date.new(2012, 11, 29))
    assert_match_array [version], @project.old_versions.to_a
    Date.stubs(:today).returns(Date.new(2012, 12, 29))
    assert_match_array [version, version2], @project.old_versions.to_a
  end

  test 'Road map data structure' do
    project = Project.find_by_id(1)
    expected_array_size = 7 #6 versions + unplanned
    expected_structure = {1 => {percent: 100, opened_issues_count: 1, closed_issues_count: 10, issues: 11},
                          2 => {percent: 80, opened_issues_count: 3, closed_issues_count: 7, issues: 10},
                          4 => {percent: 84, opened_issues_count: 5, closed_issues_count: 7, issues: 12},
                          7 => {percent: 100, opened_issues_count: 0, closed_issues_count: 4, issues: 4},
                          8 => {percent: 100, opened_issues_count: 1, closed_issues_count: 13, issues: 14},
                          12 => {percent: 100, opened_issues_count: 2, closed_issues_count: 1, issues: 3},
                          nil => {percent: 0, opened_issues_count: 7, closed_issues_count: 0, issues: 7}}
    structure = project.roadmap
    assert_equal expected_array_size, structure.keys.size
    expected_structure.each do |key, value|
      assert_equal value[:percent], structure[key][:percent].floor
      assert_equal value[:opened_issues_count], structure[key][:opened_issues_count]
      assert_equal value[:closed_issues_count], structure[key][:closed_issues_count]
      assert_equal value[:issues], structure[key][:issues].size
    end
  end

  test 'it retrieve real member' do
    role = Role.create(name: 'Role-test')
    member1 = Member.find_by_project_id_and_user_id(@project.id, User.current)
    member2 = Member.create(user_id: users(:users_002).id, project_id: @project.id, role_id: role.id)
    non_member = Member.create(user_id: users(:users_003).id, project_id: @project.id, role_id: Role.non_member.id)

    assert_match_array [member1, member2, non_member], @project.members
    assert_match_array [member1, member2], @project.real_members
  end

  test 'it retrieve non member user' do
    role = Role.create(name: 'Role-test')
    member1 = Member.find_by_project_id_and_user_id(@project.id, User.current)
    member2 = Member.create(user_id: users(:users_002).id, project_id: @project.id, role_id: role.id)
    non_member = Member.create(user_id: users(:users_003).id, project_id: @project.id, role_id: Role.non_member.id)

    all_non_members = User.all.to_a - [User.current, users(:users_002)]
    assert_match_array [member1, member2, non_member], @project.members
    assert_match_array all_non_members, @project.non_member_users.to_a
  end

  test 'it remove all non member when project change from public to private' do
    role = Role.create(name: 'Role-test')
    non_member_user = users(:users_003)
    member1 = Member.find_by_project_id_and_user_id(@project.id, User.current)
    member2 = Member.create(user_id: users(:users_002).id, project_id: @project.id, role_id: role.id)
    non_member = Member.create(user_id: non_member_user.id, project_id: @project.id, role_id: Role.non_member.id)
    watcher1 = Watcher.create(watchable_type: 'Project', watchable_id: @project.id, user_id: non_member_user.id, project_id: @project.id)
    watcher2 = Watcher.create(watchable_type: 'Issue', watchable_id: 666, user_id: non_member_user.id, project_id: @project.id)
    watcher3 = Watcher.create(watchable_type: 'Issue', watchable_id: 666, user_id: User.current.id, project_id: @project.id)

    assert watcher1.id
    assert watcher2.id
    assert watcher3.id
    assert_match_array [member1, member2, non_member], @project.members

    @project.is_public = false
    @project.save
    @project.reload
    assert_match_array [member1, member2], @project.members

    assert_raise(ActiveRecord::RecordNotFound) { watcher1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { watcher2.reload }
    assert watcher3.reload
  end

  test 'it has a method to activate modules' do
    assert_match_array Rorganize::Managers::ModuleManager.enabled_by_default_modules,
                 @project.enabled_modules.to_a.collect { |mod| {controller: mod.controller, action: mod.action, name: mod.name} }

    @project.enable_modules(['roadmaps-show-roadmaps'])
    @project.reload
    assert_equal [{controller: "roadmaps", action: "show", name: "roadmaps"}],
                 @project.enabled_modules.to_a.collect { |mod| {controller: mod.controller, action: mod.action, name: mod.name} }
  end
  # Cascade delete test.

  test 'it has many issues and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    issue = Issue.new(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: project.id)
    assert issue.save, issue.errors.messages
    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { issue.reload }
  end

  test 'it has many enables modules and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    assert EnabledModule.where(project_id: project.id).count > 0
    project.destroy
    assert EnabledModule.where(project_id: project.id).count == 0
  end

  test 'it has many documents and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    document = Document.new(name: 'Document1', project_id: project.id)
    assert document.save, document.errors.messages
    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { document.reload }
  end

  test 'it has many members and should delete them on project deletion' do
    role = Role.create(name: 'Role-test')
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    member1 = Member.find_by_project_id_and_user_id(project.id, User.current)
    member2 = Member.create(user_id: users(:users_002).id, project_id: project.id, role_id: role.id)

    assert_match_array [member1, member2], Member.where(project_id: project.id)

    project.destroy
    assert_equal [], Member.where(project_id: project.id)
  end

  test 'it has many trackers and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    project.trackers << trackers(:trackers_001)
    project.trackers << trackers(:trackers_002)
    project.save
    project.reload
    assert_match_array [trackers(:trackers_001), trackers(:trackers_002)], project.trackers

    project.destroy
  end

  test 'it has many versions and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    version = Version.new(name: 'version1', start_date: Date.new(2012, 12, 1), is_done: false)
    project.versions << version
    project.save

    assert_equal [version], Version.where(project_id: project.id)

    project.destroy
    assert_equal [], Version.where(project_id: project.id)
  end

  test 'it has many categories and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    category = Category.new(name: 'test category')
    project.categories << category
    project.save

    assert_equal [category], Category.where(project_id: project.id)

    project.destroy
    assert project.id
    assert_equal [], Category.where(project_id: project.id)
  end

  test 'it has many journals and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'created',
                             project_id: project.id, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))


    assert journal.id

    details = []
    details << JournalDetail.create(journal_id: journal.id, property: 'Assigned to', property_key: :assigned_to_id,
                                    old_value: nil, value: 'Nicolas Meylan')
    details << JournalDetail.create(journal_id: journal.id, property: 'Assigned to', property_key: :assigned_to_id,
                                    old_value: 'Nicolas Meylan', value: nil)

    journal.reload
    assert_equal details, journal.details
    assert_equal details, JournalDetail.where(journal_id: journal.id)

    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { journal.reload }
    assert_equal [], JournalDetail.where(id: details.collect(&:id))
  end

  test 'it has many comments and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: project.id, commentable_id: 2, commentable_type: 'Issue')
    issue = Issue.new(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: project.id)
    issue.comments << comment

    assert issue.save, issue.errors.messages
    assert_equal [comment], Comment.where(project_id: project.id)
    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
  end

  test 'it has many watchers and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    watcher1 = Watcher.create(watchable_type: 'Project', watchable_id: @project.id, user_id: User.current.id, project_id: project.id)
    watcher2 = Watcher.create(watchable_type: 'Issue', watchable_id: 666, user_id: User.current.id, project_id: project.id)
    watcher3 = Watcher.create(watchable_type: 'Issue', watchable_id: 666, user_id: User.current.id, project_id: project.id)

    assert_equal [watcher1, watcher2, watcher3], project.watchers
    assert_equal [watcher1, watcher2, watcher3], Watcher.where(project_id: project.id)
    project.destroy
    assert project.id
    assert_equal [], Watcher.where(project_id: project.id)
  end

  test 'it has many notifications and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    notification = Notification.create(user_id: 666, notifiable_id: 666,
                                       notifiable_type: 'Issue', project_id: project.id, from_id: User.current.id,
                                       trigger_type: 'Journal',
                                       trigger_id: 666,
                                       recipient_type: 'participants')
    assert notification.id
    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { notification.reload }
  end

  test 'it has many queries and should delete them on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    query = Query.new(author_id: User.current.id, project_id: project.id,
                      stringify_query: 'aaa', stringify_params: 'params',
                      object_type: 'Issue', name: 'my query')

    assert query.save, query.errors.messages
    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { query.reload }
  end

  test 'it has one wiki and should delete it on project deletion' do
    project = Project.create(name: 'Rorganize test fdp', is_public: true)
    wiki = Wiki.create(project_id: project.id)
    wiki_page = WikiPage.new(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    wiki.pages << wiki_page
    assert wiki.save, wiki.errors.messages
    assert wiki_page.id

    project.destroy
    assert_raise(ActiveRecord::RecordNotFound) { wiki.reload }
    assert_raise(ActiveRecord::RecordNotFound) { wiki_page.reload }
  end
end