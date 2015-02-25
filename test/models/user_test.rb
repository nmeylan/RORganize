# Author: Nicolas Meylan
# Date: 11.01.15
# Encoding: UTF-8
# File: user_test.rb
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = Project.create(name: 'Rorganize test')
    @user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @user.destroy
  end

  test 'caption should be equal to name' do
    user = users(:users_001)
    assert_equal user.name, user.caption
  end

  test 'it should generate new slug when login change' do
    assert_equal 'stdoe', @user.slug

    @user.login = 'stdoee'
    @user.save
    @user.reload
    assert_equal 'stdoee', @user.slug
  end

  test 'login should be uniq' do
    user = User.new(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doee@example.com', password: 'qwertz')
    assert_not user.save

    user.login = 'stdoee'
    assert user.save, user.errors.messages
  end

  test 'login should accept only alpha numeric value' do
    user = User.new(name: 'Steve Doe', login: 'stdoe with space', admin: 0, email: 'steve.doee@example.com', password: 'qwertz')
    assert_not user.save

    user.login = 'stdoee#specialchar'
    assert_not user.save

    user.login = 'stdoee+#specialchar'
    assert_not user.save

    user.login = 'stdoee_underscored'
    assert user.save, user.errors.messages

    user.login = 'stdoee666_1664'
    assert user.save, user.errors.messages
  end

  test "it load issues activities" do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                             project_id: 666, journalizable_identifier: 'issue1', created_at: Time.new(2012, 10, 20, 11, 1),
                             user_id: @user.id
    )
    journal1 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: 666, journalizable_identifier: 'issue2', created_at: Time.new(2012, 10, 21, 12, 1),
                              user_id: @user.id
    )
    journal2 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: 666, journalizable_identifier: 'issue3', created_at: Time.new(2012, 10, 22, 13, 1),
                              user_id: @user.id
    )
    journal3 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                              project_id: 666, journalizable_identifier: 'issue4', created_at: Time.new(2012, 10, 23, 12, 1),
                              user_id: @user.id
    )

    expected = [journal, journal1, journal2, journal3]
    actual = @user.activities(['Issue'], :ONE_WEEK, Date.new(2012, 10, 23))
    assert_match_array expected, actual

    expected = [journal, journal1, journal2]
    actual = @user.activities(['Issue'], :THREE_DAYS, Date.new(2012, 10, 22))
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
    issues_comments << Comment.create({content: 'this a comment', user_id: @user.id, project_id: 666,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date1})

    documents_comments << Comment.create({content: 'this a comment', user_id: @user.id, project_id: 666,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date2})

    issues_comments << Comment.create({content: 'this a comment', user_id: @user.id, project_id: 666,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date3})

    documents_comments << Comment.create({content: 'this a comment', user_id: @user.id, project_id: 666,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date4})

    documents_comments << Comment.create({content: 'this a comment', user_id: @user.id, project_id: 666,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date5})

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array issues_comments,
                       @user.comments_for(['Issue'], period, range_end_date).to_a

    assert_match_array documents_comments[0, 1],
                       @user.comments_for(['Document'], period, range_end_date).to_a

    assert_match_array issues_comments + documents_comments[0, 1],
                       @user.comments_for(['Issue', 'Document'], period, range_end_date).to_a

    range_end_date = Date.new(2001, 2, 4)
    period = :ONE_WEEK
    assert_match_array issues_comments,
                       @user.comments_for(['Issue'], period, range_end_date).to_a

    assert_match_array documents_comments,
                       @user.comments_for(['Document'], period, range_end_date).to_a

    assert_match_array issues_comments + documents_comments,
                       @user.comments_for(['Issue', 'Document'], period, range_end_date).to_a
  end

  test 'he is a member in many project' do
    role = Role.create(name: 'Seller')
    role1 = Role.create(name: 'Quality')
    member = Member.create(user_id: @user.id, project_id: 666, role_id: role.id)
    member1 = Member.create(user_id: @user.id, project_id: 667, role_id: role1.id)

    assert_equal member, @user.member_for(666)
    assert_equal 'Seller', @user.member_for(666).role.name
    assert_equal member1, @user.member_for(667)
    assert_equal 'Quality', @user.member_for(667).role.name
  end

  test 'he can assign the following roles' do
    role = Role.set_role_attributes({name: 'Master'}, {issues_statuses: {"New" => "1", "In progress" => "2"},
                                                       roles: {"Project Manager" => "1", "Team Member" => "2"}})
    assert role.save, role.errors.messages
    member = Member.create(user_id: @user.id, project_id: @project.id, role_id: role.id)
    roles = Role.where(id: [1, 2]).to_a
    assert_equal roles, @user.allowed_roles(@project).to_a

    @user.admin = true
    assert @user.save, @user.errors.messages
    @user.act_as_admin('Admin')
    roles = Role.where(is_locked: false).to_a
    assert_equal roles, @user.allowed_roles(@project).to_a
    @user.act_as_admin('User')
  end

  test 'is he admin' do
    assert_not @user.is_admin?
    @user.admin = true
    assert @user.save, @user.errors.messages
    assert @user.is_admin?
  end

  test 'get current user' do
    assert_equal users(:users_001), User.current
  end

  test 'set current user' do
    user2 = users(:users_002)
    User.current = user2
    assert_equal user2, User.current

    User.current = users(:users_001)
    assert_equal users(:users_001), User.current
  end

  test 'he can act as admin' do
    assert_not @user.act_as_admin?
    @user.act_as_admin('Admin')
    assert @user.act_as_admin?
    @user.act_as_admin('User')
    assert_not @user.act_as_admin?
  end

  test 'he has time entries' do
    time_entry = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2012, 12, 23), user_id: @user.id)
    time_entry1 = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2012, 12, 2), user_id: @user.id)
    time_entry2 = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2012, 11, 23), user_id: @user.id)
    time_entry3 = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2011, 11, 23), user_id: @user.id)
    assert time_entry.save, time_entry.errors.messages
    assert time_entry1.save, time_entry1.errors.messages
    assert time_entry2.save, time_entry2.errors.messages
    assert time_entry3.save, time_entry3.errors.messages

    assert_match_array [time_entry1, time_entry], @user.time_entries_for_month(2012, 12)
    assert_match_array [time_entry2], @user.time_entries_for_month(2012, 11)
    assert_match_array [time_entry3], @user.time_entries_for_month(2011, 11)
    assert_match_array [], @user.time_entries_for_month(2011, 10)
  end

  test 'he can set issues statuses but it limited by his role' do
    role = Role.set_role_attributes({name: 'Master'}, {issues_statuses: {"New" => "1", "In progress" => "2"},
                                                       roles: {"Project Manager" => "1", "Team Member" => "2"}})
    assert role.save, role.errors.messages
    member = Member.create(user_id: @user.id, project_id: @project.id, role_id: role.id)
    statuses = IssuesStatus.where(id: [1, 2]).joins(:enumeration).order('enumerations.position ASC').to_a
    assert_equal statuses, @user.allowed_statuses(@project).to_a


    role = Role.find_by_name('Anonymous')
    anonymous = users(:users_002)
    assert_equal role.issues_statuses, anonymous.allowed_statuses(@project).to_a

    role = Role.find_by_name('Non member')
    @project.is_public = true
    assert @project.save, @project.errors.messages
    non_member = users(:users_002)
    assert_equal role.issues_statuses, non_member.allowed_statuses(@project).to_a
  end

  test 'he can retrieve all of his owned projects' do
    assert_equal [], @user.owned_projects('all')

    role = roles(:roles_001)
    member = Member.create(user_id: @user.id, project_id: @project.id, role_id: role.id, project_position: 0)
    archived_project = Project.new(name: 'Rorganize test archived', is_archived: true)
    starred_project = Project.new(name: 'Rorganize test starred')
    archived_starred_project = Project.new(name: 'Rorganize test archived starred', is_archived: true)

    assert archived_project.save, archived_project.errors.messages
    assert starred_project.save, starred_project.errors.messages
    assert archived_starred_project.save, archived_starred_project.errors.messages

    assert_equal [@project], @user.owned_projects('all').to_a
    assert_match_array [@project], @user.owned_projects('all').to_a

    archived_project.is_public = true
    assert archived_project.save, archived_project.errors.messages
    assert_match_array [@project, archived_project], @user.owned_projects('all').to_a

    member1 = Member.create(user_id: @user.id, project_id: archived_project.id, role_id: role.id, project_position: 1)
    member.project_position = 1
    member1.project_position = 0
    assert member.save, member.errors.messages
    assert member1.save, member1.errors.messages
    assert_match_array [archived_project, @project], @user.owned_projects('all').to_a

    assert_match_array [@project], @user.owned_projects('opened').to_a
    assert_match_array [archived_project], @user.owned_projects('archived').to_a

    member2 = Member.create(user_id: @user.id, project_id: starred_project.id, role_id: role.id, is_project_starred: true)
    member3 = Member.create(user_id: @user.id, project_id: archived_starred_project.id, role_id: role.id, is_project_starred: true)
    member2.project_position = 3
    member3.project_position = 2
    assert member2.save, member2.errors.messages
    assert member3.save, member3.errors.messages
    assert_match_array [archived_starred_project, starred_project], @user.owned_projects('starred').to_a
  end

  test 'it has receive notifications' do
    assert_equal 0, @user.count_notification
    assert_not @user.notified?

    notification = Notification.create(user_id: @user.id, notifiable_id: 666,
                                       notifiable_type: 'Issue', project_id: 1, from_id: 666,
                                       trigger_type: 'Journal',
                                       trigger_id: 666,
                                       recipient_type: 'participants')
    assert_equal 1, @user.count_notification
    assert @user.notified?
  end

  test 'it should not saved with invalid name or login' do
    user = User.new(admin: 0, email: 'stevea.doe@example.com', password: 'qwertz')
    assert_not user.save

    user = User.new(name: 'Ste', login: 'std', admin: 0, email: 'stevea.doe@example.com', password: 'qwertz')
    assert_not user.save

    user = User.new(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz')
    assert_not user.save

    user = User.new(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe@example.com')
    assert_not user.save

    user = User.new(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')
    assert user.save, user.errors.messages
  end

  test 'it has many notifications and should delete them on project deletion' do
    user = User.create(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')
    notification = Notification.create(user_id: user.id, notifiable_id: 666,
                                       notifiable_type: 'Issue', project_id: 1, from_id: 666,
                                       trigger_type: 'Journal',
                                       trigger_id: 666,
                                       recipient_type: 'participants')
    assert_equal 1, user.count_notification
    user.destroy

    assert_raise(ActiveRecord::RecordNotFound) { notification.reload }
  end

  test 'it has many members and should delete them on project deletion' do
    user = User.create(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')

    member = Member.create(user_id: user.id, project_id: @project.id, role_id: 666, is_project_starred: true)
    user.destroy

    assert_raise(ActiveRecord::RecordNotFound) { member.reload }
  end

  test 'it has many preferences and should delete them on project deletion' do
    user = User.create(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')
    assert user.preferences.count > 0
    preferences_ids = user.preferences.collect(&:id)
    assert_equal user.preferences, Preference.where(id: preferences_ids)
    user.destroy
    assert_equal [], Preference.where(id: preferences_ids)
  end

  test 'it generate a default avatar' do
    user = User.create!(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')

    assert_nil user.avatar
    user.generate_default_avatar!
    assert_not_nil user.avatar
    assert_equal 'stdaaa_default_avatar.png', user.avatar.avatar_file_name
  end

  test 'it delete avatar when user has changed his default avatar and regenerate his default avatar' do
    user = User.create!(name: 'Steaaa', login: 'stdaaa', admin: 0, password: 'qwertz', email: 'steve.doe.uniq@example.com')

    assert 0, Avatar.where(attachable_id: user.id, attachable_type: 'User').count
    assert_nil user.avatar
    user.generate_default_avatar!
    assert 1, Avatar.where(attachable_id: user.id, attachable_type: 'User').count
    assert_not_nil user.avatar
    assert_equal 'stdaaa_default_avatar.png', user.avatar.avatar_file_name

    user.avatar.avatar_file_name = 'new_avatar.png' # change default avatar
    user.avatar.save
    user.avatar.reload

    assert_equal 'new_avatar.png', user.avatar.avatar_file_name
    user.delete_avatar
    assert 1, Avatar.where(attachable_id: user.id, attachable_type: 'User').count
    assert_equal 'stdaaa_default_avatar.png', user.avatar.avatar_file_name
  end
end