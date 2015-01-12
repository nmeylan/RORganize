# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issue_test.rb
# require 'test/unit'
require 'test_helper'
class IssueTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: 1, due_date: '2012-12-31')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @issue.destroy
  end

  test 'Journal creation on issue create' do
    journal = Journal.find_by_journalizable_id_and_journalizable_type(@issue.id, 'Issue')
    assert_not_nil(journal)
  end

  test 'Journal creation on issue update' do
    @issue.attributes = {tracker_id: 2}
    @issue.save
    journal = Journal.where(journalizable_id: @issue.id, journalizable_type: 'Issue').order('id desc').first
    journal_details = journal.details.to_a
    assert_equal(1, journal_details.size)
    assert_equal('tracker_id', journal_details.first.property_key)
  end

  test 'it set done ratio when status change' do
    #Status 4 is "Fixed to test", default done value is 100
    @issue.attributes = {status_id: 4}
    @issue.save
    assert_equal(100, @issue.done)
  end

  test 'it does not set done ratio when status change and done ratio at the same time' do
    #Status 4 is "Fixed to test", default done value is 100
    @issue.attributes = {status_id: 4, done: 50}
    @issue.save
    assert_equal(50, @issue.done)

    #Status 8 default done value is nil
    @issue.attributes = {status_id: 8, done: 50}
    @issue.save
    assert_equal(50, @issue.done)
  end

  test 'it set done ratio on creation' do
    #Status 4 is "Fixed to test", default done value is 100
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '4', project_id: 1)
    issue1.save
    assert_equal 100, issue1.done

    #Status 8 default done value is nil
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1)
    issue1.save
    assert_equal 0, issue1.done
  end

  test 'it set done ratio when status change on bulk edit' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, done: 0)
    issue3 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, done: 10)

    issue_ids = []
    issue_ids << issue1.id << issue2.id << issue3.id

    assert_equal 50, issue1.done
    assert_equal 0, issue2.done
    assert_equal 10, issue3.done

    #Status 8 default done value is nil
    Issue.bulk_set_done_ratio(issue_ids, 8, nil)

    issue1.reload
    assert_equal 50, issue1.done

    issue2.reload
    assert_equal 0, issue2.done

    issue3.reload
    assert_equal 10, issue3.done

    #Status 3 default done value is 100
    Issue.bulk_set_done_ratio(issue_ids, 3, nil)

    issue1.reload
    assert_equal 100, issue1.done

    issue2.reload
    assert_equal 100, issue2.done

    issue3.reload
    assert_equal 100, issue3.done

    #Status 6 default done value is 50
    Issue.bulk_set_done_ratio(issue_ids, 6, nil)

    issue1.reload
    assert_equal 50, issue1.done

    issue2.reload
    assert_equal 50, issue2.done

    issue3.reload
    assert_equal 50, issue3.done
  end

  test 'Filtered attributes' do
    expectation = [['Subject', 'subject'], ['Created at', 'created_at'], ['Updated at', 'updated_at'],
                   ['Due date', 'due_date'], ['Done', 'done'], ['Author', 'author'], ['Assigned to', 'assigned_to'],
                   ['Tracker', 'tracker'], ['Status', 'status'], ['Version', 'version'], ['Category', 'category'],
                   ['Start date', 'start_date'], ["User story", "user_story"]]
    actual = Issue.filtered_attributes
    assert_equal expectation, actual
  end

  test 'Attributes_formalized_names' do
    expectation = ['Subject', 'Description', 'Created at', 'Updated at', 'Due date',
                   'Done', 'Author', 'Assigned to', 'Project', 'Tracker', 'Status',
                   'Version', 'Category', 'Estimated time', 'Start date', 'Predecessor',
                   'Attachments count', 'Comments count', 'Link type', "User story"]
    actual = Issue.attributes_formalized_names
    assert_equal expectation, actual
  end

  test 'it may contains a task list into the description' do
    @issue.description = '- [ ] A
- [ ] B
- [ ] C'
    assert_equal true, @issue.has_task_list?
    @issue.description = '- A
- [ B
@ aaa'
    assert_equal false, @issue.has_task_list?
  end
  test 'Count checked tasks in task list' do
    @issue.description = '- [ ] A
- [ ] B
- [ ] C'
    assert_equal 0, @issue.count_checked_tasks

    @issue.description = '- [ ] A
- [ ] B
- [x] C'
    assert_equal 1, @issue.count_checked_tasks
    @issue.description = '- [x] A
- [ ] B
bla bla
- [x] C'
    assert_equal 2, @issue.count_checked_tasks
    assert_equal 3, @issue.count_tasks

    @issue.description = ' a'
    assert_equal 0, @issue.count_tasks
  end

  test 'it can be open or close depending on the status' do
    opened_status = issues_statuses(:issues_statuses_001)
    closed_status = issues_statuses(:issues_statuses_003)

    @issue.status = opened_status
    @issue.save
    @issue.reload
    assert @issue.open?

    @issue.status = closed_status
    @issue.save
    @issue.reload
    assert_not @issue.open?
  end

  test 'permit attributes should contains' do
    expectation = [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id,
                   :start_date, :subject, :description, :tracker_id, :due_date, :estimated_time,
                   {new_attachment_attributes: Attachment.permit_attributes},
                   {edit_attachment_attributes: Attachment.permit_attributes}]

    assert_match_array expectation, Issue.permit_attributes
  end

  test 'permit bulk edit attributes should contains' do
    expectation = [:assigned_to_id, :author_id, :version_id, :done, :category_id, :status_id, :start_date]
    assert_match_array expectation, Issue.permit_bulk_edit_values
  end

  test 'caption should be equal to subject' do
    assert_equal @issue.subject, @issue.caption
  end

  test 'condition string' do
    actual = Issue.conditions_string({'category' => {'operator' => 'equal', 'value' => ['1', '2']}})
    expected = '(issues.category_id <=> \'1\' OR issues.category_id <=> \'2\' ) AND'
    assert_equal expected, actual

    actual = Issue.conditions_string({'subject' => {'operator' => 'contains', 'value' => 'hello'}})
    expected = 'issues.subject LIKE "%hello%" AND'
    assert_equal expected, actual

    actual = Issue.conditions_string({'done' => {'operator' => 'equal', 'value' => ['10']},
                                      'version' => {'operator' => 'different', 'value' => ['1', '2']}
                                     })
    expected = '(issues.done <=> \'10\' ) AND (issues.version_id <> \'1\' AND issues.version_id <> \'2\' OR issues.version_id IS NULL ) AND'
    assert_equal expected, actual

    actual = Issue.conditions_string({'status' => {'operator' => 'close', 'value' => ''}})
    expected = '(issues.status_id <=> 3 OR issues.status_id <=> 9 ) AND'
    assert_equal expected, actual

    actual = Issue.conditions_string({'status' => {'operator' => 'open', 'value' => ''}})
    expected = '(issues.status_id <=> 1 OR issues.status_id <=> 2 OR issues.status_id <=> 4 '
    expected += 'OR issues.status_id <=> 5 OR issues.status_id <=> 6 OR issues.status_id <=> 7 '
    expected += 'OR issues.status_id <=> 8 ) AND'
    assert_equal expected, actual
  end

  test 'it load all project 666 issues' do
    issues1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: '4', project_id: 666)
    issues2 = Issue.create(tracker_id: 1, subject: 'Bug2', status_id: '4', project_id: 666)
    issues3 = Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '4', project_id: 666)
    issues = []
    issues << issues1 << issues2 << issues3
    assert_equal issues, Issue.paginated_issues_method(1, '', 'id ASC', 100, 666)
    assert_equal issues.reverse, Issue.paginated_issues_method(1, '', 'issues.subject DESC', 100, 666)
    assert_equal issues.reverse, Issue.prepare_paginated(1, 100, 'issues.subject DESC', '', 666).to_a

    issue_conditions_string = Issue.conditions_string({'subject' => {'operator' => 'contains', 'value' => 'bug'}})
    assert_equal issues, Issue.paginated_issues_method(1, issue_conditions_string, 'issues.id ASC', 100, 666)
    assert_equal issues, Issue.prepare_paginated(1, 100, 'issues.id ASC', issue_conditions_string, 666).to_a

    issue_conditions_string = Issue.conditions_string({'subject' => {'operator' => 'contains', 'value' => 'bug1'}})
    assert_equal issues[0, 1], Issue.paginated_issues_method(1, issue_conditions_string, 'issues.id ASC', 100, 666)
    assert_equal issues[0, 1], Issue.prepare_paginated(1, 100, 'issues.id ASC', issue_conditions_string, 666).to_a
  end

  test 'scope group by status' do
    project = Project.create(name: 'test project')
    Issue.create(tracker_id: 1, subject: 'Bug1', status_id: '4', project_id: project.id)
    Issue.create(tracker_id: 1, subject: 'Bug2', status_id: '4', project_id: project.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '4', project_id: project.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '5', project_id: project.id)

    group_result = Issue.group_by_status_method(project.id)
    expectation = [[4, 'Fixed to test', 3, 'test-project'], [5, 'Tested to be delivered', 1, 'test-project']]
    assert_equal expectation, group_result
  end

  test 'scope opened issues by attribute' do
    project = Project.create(name: 'test project')
    user1 = users(:users_001)
    user2 = users(:users_002)
    user3 = users(:users_003)
    Issue.create(tracker_id: 1, subject: 'Bug1', status_id: '4', project_id: project.id, assigned_to_id: user1.id)
    Issue.create(tracker_id: 1, subject: 'Bug2', status_id: '4', project_id: project.id, assigned_to_id: user1.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '4', project_id: project.id, assigned_to_id: user2.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '5', project_id: project.id, assigned_to_id: user3.id)

    group_result = Issue.group_opened_by_attr_method('assigned_to', '1=1', project.id, 'users')
    expectation = [[user1.id, 'Nicolas Meylan', 2, 'test-project'],
                   [user2.id, 'James Bond', 1, 'test-project'],
                   [user3.id, 'Roger Smith', 1, 'test-project']]
    assert_equal expectation, group_result
  end

  test 'scope opened issues by project' do
    project = Project.create(name: 'test project')
    project1 = Project.create(name: 'test project1')
    user1 = users(:users_001)
    Issue.create(tracker_id: 1, subject: 'Bug1', status_id: '4', project_id: project.id, assigned_to_id: user1.id)
    Issue.create(tracker_id: 1, subject: 'Bug2', status_id: '4', project_id: project.id, assigned_to_id: user1.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '4', project_id: project1.id, assigned_to_id: user1.id)
    Issue.create(tracker_id: 1, subject: 'Bug3', status_id: '5', project_id: project1.id, assigned_to_id: user1.id)

    group_result = Issue.group_opened_by_project_method('issues.assigned_to_id',
                                                        "issues.assigned_to_id = #{user1.id} AND project_id IN (#{project.id},#{project1.id})")
    expectation = [[user1.id, project.id, "test-project", 2, "test-project"],
                   [user1.id, project1.id, "test-project1", 2, "test-project1"]]

    assert_equal expectation, group_result
  end

  #######################
  ###    VALIDATORS   ###
  #######################

  test 'it should not save with an empty subject' do
    issue = Issue.new(tracker_id: 1, status_id: '4', project_id: 1)
    assert_not issue.save
    issue.subject = 'Bug'
    assert issue.save, issue.errors.messages
  end

  test 'it should not save with an empty tracker' do
    issue = Issue.new(subject: 'Bug', status_id: '4', project_id: 1)
    assert_not issue.save
    issue.tracker_id = 1
    assert issue.save, issue.errors.messages
  end

  test 'it should not save with an empty status' do
    issue = Issue.new(tracker_id: 1, subject: 'Bug',project_id: 1)
    assert_not issue.save
    issue.status_id = 4
    assert issue.save, issue.errors.messages
  end
end