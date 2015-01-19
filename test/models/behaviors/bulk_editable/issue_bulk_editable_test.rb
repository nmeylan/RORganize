# Author: Nicolas Meylan
# Date: 19.01.15 09:59
# Encoding: UTF-8
# File: issue_bulk_editable_test.rb
require 'test_helper'

class IssueBulkEditableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1',
                          done: 10, project_id: 1, start_date: '2012-12-01', due_date: '2012-12-31')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  test 'it create a journal with details on bulk edition' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '3', project_id: 1, done: 20)
    issue_ids = [issue1.id, issue2.id]
    Issue.bulk_edit(issue_ids, {'done' => 100}, @project)
    journal_issue1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_UPDATE)
    journal_issue2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_UPDATE)

    assert journal_issue1
    assert journal_issue2

    details_issue1 = journal_issue1.details
    details_issue2 = journal_issue2.details

    assert_equal 1, details_issue1.count
    assert_equal 1, details_issue2.count

    assert_equal 'done', details_issue1.first.property_key
    assert_equal '50', details_issue1.first.old_value
    assert_equal '100', details_issue1.first.value

    assert_equal 'done', details_issue2.first.property_key
    assert_equal '20', details_issue2.first.old_value
    assert_equal '100', details_issue2.first.value
  end

  test 'it create a journal with details on bulk edition through association' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '3', project_id: 1, done: 20)
    issue3 = Issue.create(tracker_id: 2, subject: 'Bug', status_id: '3', project_id: 1, done: 20)
    issue_ids = [issue1.id, issue2.id, issue3.id]

    Issue.bulk_edit(issue_ids, {'tracker_id' => 2}, @project)
    journal_issue1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_UPDATE)
    journal_issue2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_UPDATE)
    journal_issue3 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue3.id, 'Issue', Journal::ACTION_UPDATE)

    assert journal_issue1
    assert journal_issue2
    assert_not journal_issue3 # has not changed

    details_issue1 = journal_issue1.details
    details_issue2 = journal_issue2.details

    assert_equal 1, details_issue1.count
    assert_equal 1, details_issue2.count

    assert_equal 'tracker_id', details_issue1.first.property_key
    assert_equal 'Task', details_issue1.first.old_value
    assert_equal 'Bug', details_issue1.first.value

    assert_equal 'tracker_id', details_issue2.first.property_key
    assert_equal 'Task', details_issue2.first.old_value
    assert_equal 'Bug', details_issue2.first.value
  end

  test 'it create a journal when issues status are bulk edited with 2 details status and done ratio details' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 20)
    issue_ids = [issue1.id, issue2.id]
    Issue.bulk_edit(issue_ids, {status_id: 4}, @project)

    journal_issue1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_UPDATE)
    journal_issue2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_UPDATE)

    assert journal_issue1
    assert journal_issue2

    details_issue1 = journal_issue1.details
    details_issue2 = journal_issue2.details

    assert_equal 2, details_issue1.count
    assert_equal 2, details_issue2.count

    assert_equal 'status_id', details_issue1[0].property_key
    assert_equal 'In progress bis', details_issue1[0].old_value
    assert_equal 'Fixed to test', details_issue1[0].value

    assert_equal 'done', details_issue1[1].property_key
    assert_equal '50', details_issue1[1].old_value
    assert_equal '100', details_issue1[1].value


    assert_equal 'status_id', details_issue2[0].property_key
    assert_equal 'In progress bis', details_issue2[0].old_value
    assert_equal 'Fixed to test', details_issue2[0].value

    assert_equal 'done', details_issue2[1].property_key
    assert_equal '20', details_issue2[1].old_value
    assert_equal '100', details_issue2[1].value
  end

  test 'it create a journal when issues version are bulk edited with 1 detail version' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-01', project_id: @project.id)
    Issue.bulk_edit([@issue.id], {version_id: version.id}, @project)
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 1, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal '', version_update_detail.old_value
    assert_equal 'Release 1.0', version_update_detail.value
  end

  test 'it create a journal when issues version are edited with 2 detail for version and start date' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-02', project_id: @project.id)
    Issue.bulk_edit([@issue.id], {version_id: version.id}, @project)

    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 2, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal '', version_update_detail.old_value
    assert_equal 'Release 1.0', version_update_detail.value

    start_date_update_detail = details[1]
    assert_equal 'start_date', start_date_update_detail.property_key
    assert_equal '2012-12-01', start_date_update_detail.old_value
    assert_equal '2012-12-02', start_date_update_detail.value
  end

  test 'it create a journal when issues version are edited with 3 detail for version and start date and due date' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-02', target_date: '2012-12-29', project_id: @project.id)
    Issue.bulk_edit([@issue.id], {version_id: version.id}, @project)
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 3, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal '', version_update_detail.old_value
    assert_equal 'Release 1.0', version_update_detail.value

    due_date_update_detail = details[1]
    assert_equal 'due_date', due_date_update_detail.property_key
    assert_equal '2012-12-31', due_date_update_detail.old_value
    assert_equal '2012-12-29', due_date_update_detail.value

    start_date_update_detail = details[2]
    assert_equal 'start_date', start_date_update_detail.property_key
    assert_equal '2012-12-01', start_date_update_detail.old_value
    assert_equal '2012-12-02', start_date_update_detail.value
  end

  test 'it delete all journals and details when issues are bulk deleted' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    Issue.bulk_edit([issue1.id, issue2.id], {status_id: 4}, @project)

    journal_creation_issue1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_CREATE)
    journal_issue1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_UPDATE)
    details_issue1 = journal_issue1.details
    assert journal_creation_issue1
    assert journal_issue1
    assert_equal 2, details_issue1.count

    journal_creation_issue2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_CREATE)
    journal_issue2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_UPDATE)
    details_issue2 = journal_issue2.details
    assert journal_creation_issue2
    assert journal_issue2
    assert_equal 2, details_issue2.count

    Issue.bulk_delete([issue1.id, issue2.id], @project)

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_issue1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_issue1.reload }
    assert_not details_issue1[0]
    assert_not details_issue1[1]

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_issue2.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_issue2.reload }
    assert_not details_issue2[0]
    assert_not details_issue2[1]
  end

  test 'it create a journal when issues are bulk deleted' do
    issue1 = Issue.create(tracker_id: 1, subject: 'This is my issue 1 subject', status_id: '8', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'This is my issue 2 subject', status_id: '8', project_id: 1, done: 50)

    Issue.bulk_delete([issue1.id, issue2.id], @project)

    journals_count = Journal.where(journalizable_type: 'Issue', journalizable_id: issue1.id).count
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_DELETE)
    assert_equal 1, journals_count
    assert journal
    assert_equal 'This is my issue 1 subject', journal.journalizable_identifier

    journals_count = Journal.where(journalizable_type: 'Issue', journalizable_id: issue2.id).count
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue2.id, 'Issue', Journal::ACTION_DELETE)
    assert_equal 1, journals_count
    assert journal
    assert_equal 'This is my issue 2 subject', journal.journalizable_identifier
  end
end