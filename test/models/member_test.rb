# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: member_test.rb
require 'test_helper'

class MemberTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = users(:users_001)
    @role = Role.create(name: 'Role-test')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'caption should be equal to user name' do
    @project = Project.create(name: 'RORganize-test')
    @member = Member.create(user_id: @user.id, project_id: @project.id, role_id: @role.id)

    assert_equal @user.name, @member.caption
    assert_equal 'Nicolas Meylan', @member.caption
  end

  test 'it should create a journal on member creation' do
    project = Project.create(name: 'RORganize-test-bis')
    user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
    member = Member.create(user_id: user.id, project_id: project.id, role_id: @role.id)

    journal = Journal.find_by_journalizable_id_and_journalizable_type(member.id, 'Member')
    detail = JournalDetail.find_by_journal_id(journal.id)
    assert journal
    assert_equal nil, detail.old_value
    assert_equal @role.name, detail.value
  end

  test 'it should change role' do
    @project = Project.create(name: 'RORganize-test')
    @member = Member.create(user_id: @user.id, project_id: @project.id, role_id: @role.id)

    role = Role.create(name: 'Role-test')
    assert_equal @role.id, @member.role_id

    result = @member.change_role(role.id)
    assert_equal role.id, @member.role_id
    assert result[:saved]
  end

  test 'it should set project position on creation' do
    @project = Project.create(name: 'RORganize-test')
    @member = Member.create(user_id: @user.id, project_id: @project.id, role_id: @role.id)

    project = Project.create(name: 'RORganize-test-bis')
    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role.id)

    assert_equal 3, @member.project_position
    assert_equal 4, member.project_position
  end

  test 'it should unassign issues when member is deleted' do
    project = Project.create(name: 'RORganize-test-bis')
    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role.id)
    issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: 1, assigned_to_id: member.user_id)

    assert_equal @user.id, member.user_id
    assert_equal @user.id, issue.assigned_to_id

    member.destroy
    issue.reload
    assert_equal nil, issue.assigned_to_id
  end

  test 'it should remove all watchers entry' do
    project = Project.create(name: 'RORganize-test-bis')
    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role.id)
    issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: 1)
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: 1)
    watcher = Watcher.new(watchable_id: issue.sequence_id, watchable_type: 'Issue', user_id: @user.id, project_id: project.id)
    watcher1 = Watcher.new(watchable_id: issue1.id, watchable_type: 'Issue', user_id: @user.id, project_id: project.id)
    assert watcher.save, watcher.errors.messages
    assert watcher1.save, watcher1.errors.messages

    member.destroy
    assert_raises(ActiveRecord::RecordNotFound) { watcher.reload }
    assert_raises(ActiveRecord::RecordNotFound) { watcher1.reload }
  end

  test 'it should remove old role if user was a non member to the project' do
    project = Project.create(name: 'RORganize-test-bis', is_public: true)
    non_member_role_id = Role.non_member.id
    member = Member.create(user_id: @user.id, project_id: project.id, role_id: non_member_role_id)

    assert non_member_role_id, member.role.id
    assert Member.find_by_project_id_and_user_id_and_role_id(project.id, @user.id, non_member_role_id)

    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role.id)

    assert @role.id, member.role.id
    assert_not Member.find_by_project_id_and_user_id_and_role_id(project.id, @user.id, non_member_role_id)
    assert Member.find_by_project_id_and_user_id_and_role_id(project.id, @user.id, @role.id)
  end

  test 'it should update project counter cache except when member has a non member role' do
    project = Project.create(name: 'RORganize-test-bis')

    assert 0, project.members_count
    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role_id)
    project.reload
    assert 1, project.members_count

    member.destroy
    project.reload
    assert 0, project.members_count

    member = Member.create(user_id: @user.id, project_id: project.id, role_id: Role.non_member.id)
    project.reload
    assert 0, project.members_count

    member.destroy
    project.reload
    assert 0, project.members_count

    member = Member.create(user_id: @user.id, project_id: project.id, role_id: @role_id)
    project.reload
    assert 1, project.members_count
  end

  test 'member should be uniq for the same project and same role' do
    project = Project.create(name: 'RORganize-test')
    member = Member.new(user_id: @user.id, project_id: project.id, role_id: @role.id)
    member1 = Member.new(user_id: @user.id, project_id: project.id, role_id: @role.id)

    assert member.save, member.errors.messages
    assert_not member1.save

    member1 = Member.new(user_id: @user.id, project_id: project.id, role_id: 666)
    assert member1.save, member1.errors.messages
  end

  test 'it should not be possible to add user when non member role on a private project' do
    project = Project.create(name: 'RORganize-test', is_public: false)
    member = Member.new(user_id: @user.id, project_id: project.id, role_id: Role.non_member.id)
    assert_not member.save

    project1 = Project.create(name: 'RORganize-test1', is_public: true)
    member = Member.new(user_id: @user.id, project_id: project1.id, role_id: Role.non_member.id)
    assert member.save, member.errors.messages
  end

  test 'member should not be saved if role project or user are missing' do
    project = Project.create(name: 'RORganize-test', is_public: true)
    member = Member.new(user_id: @user.id, project_id: project.id)
    assert_not member.save

    member = Member.new(project_id: project.id, role_id: Role.non_member.id)
    assert_not member.save

    member = Member.new(user_id: @user.id, role_id: Role.non_member.id)
    assert_not member.save

    member = Member.new(user_id: @user.id, project_id: project.id, role_id: Role.non_member.id)
    assert member.save, member.errors.messages
  end
end