# Author: Nicolas Meylan
# Date: 16.01.15 16:20
# Encoding: UTF-8
# File: issue_journalizable_test.rb
require 'test_helper'

class IssueJournalizableTest < ActiveSupport::TestCase

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

  test "it create a journal when issue has been created" do
    journal = Journal.find_by_journalizable_id_and_journalizable_type(@issue.id, 'Issue')
    assert Journal::ACTION_CREATE, journal.action_type
  end

  test "it create a journal when subject is updated" do
    @issue.update_attribute(:subject, 'Issue update')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 1, details.count

    subject_update_detail = details.first
    assert_equal 'subject', subject_update_detail.property_key
    assert_equal 'Issue creation', subject_update_detail.old_value
    assert_equal 'Issue update', subject_update_detail.value
  end

  test 'it create a journal when an attribute and an excluded one have changed' do
    @issue.update_attributes({subject: 'Issue update', description: 'My description'})
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 1, details.count

    subject_update_detail = details.first
    assert_equal 'subject', subject_update_detail.property_key
    assert_equal 'Issue creation', subject_update_detail.old_value
    assert_equal 'Issue update', subject_update_detail.value
  end

  test 'it create a journal with a detail for each updated attributes' do
    @issue.update_attributes({subject: 'Issue update', done: 20})
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 2, details.count

    subject_update_detail = details.first
    assert_equal 'subject', subject_update_detail.property_key
    assert_equal 'Issue creation', subject_update_detail.old_value
    assert_equal 'Issue update', subject_update_detail.value

    done_update_detail = details[1]
    assert_equal 'done', done_update_detail.property_key
    assert_equal '10', done_update_detail.old_value
    assert_equal '20', done_update_detail.value
  end

  test 'it create a journal with a detail for each updated attributes even through association' do
    @issue.update_attributes({status_id: 8,  tracker_id: 2})
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal
    assert_equal 2, details.count

    status_update_detail = details.first
    assert_equal 'status_id', status_update_detail.property_key
    assert_equal 'New', status_update_detail.old_value
    assert_equal 'In progress bis', status_update_detail.value

    tracker_update_detail = details[1]
    assert_equal 'tracker_id', tracker_update_detail.property_key
    assert_equal 'Task', tracker_update_detail.old_value
    assert_equal 'Bug', tracker_update_detail.value
  end

  test 'it create a journal when status has been edited with two detail status and done ratio' do
    @issue.update_attribute(:status_id, 4)
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal
    assert_equal 2, details.count

    status_update_detail = details.first
    assert_equal 'status_id', status_update_detail.property_key
    assert_equal 'New', status_update_detail.old_value
    assert_equal 'Fixed to test', status_update_detail.value

    done_update_detail = details[1]
    assert_equal 'done', done_update_detail.property_key
    assert_equal '10', done_update_detail.old_value
    assert_equal '100', done_update_detail.value
  end

  test 'it create a journal when version has been edited with 1 detail for version' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-01', project_id: @project.id)
    @issue.version = version
    @issue.save
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 1, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal nil, version_update_detail.old_value
    assert_equal 'Release 1.0', version_update_detail.value
  end

  test 'it create a journal when version has been edited with 2 detail for version and start date' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-02', project_id: @project.id)
    @issue.version = version
    @issue.save
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 2, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal nil, version_update_detail.old_value
    assert_equal 'Release 1.0', version_update_detail.value

    start_date_update_detail = details[1]
    assert_equal 'start_date', start_date_update_detail.property_key
    assert_equal '2012-12-01', start_date_update_detail.old_value
    assert_equal '2012-12-02', start_date_update_detail.value
  end

  test 'it create a journal when version has been edited with 3 detail for version and start date and due date' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-02', target_date: '2012-12-29', project_id: @project.id)
    @issue.version = version
    @issue.save
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert journal
    details = journal.details
    assert_equal 3, details.count

    version_update_detail = details.first
    assert_equal 'version_id', version_update_detail.property_key
    assert_equal nil, version_update_detail.old_value
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

  test 'it delete all journals and details when issue is deleted' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    issue1.update_attribute(:status_id, 4)
    journal_creation = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_CREATE)
    assert journal_creation
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal
    assert_equal 2, details.count

    issue1.destroy
    assert_raise(ActiveRecord::RecordNotFound) { journal_creation.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal.reload }
    assert_not details[0]
    assert_not details[1]
  end

  test 'it delete all journals and details when bulk delete dependent is called' do
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    document = Document.create(name: 'Document creation', project_id: @project.id)
    Issue.bulk_edit([issue1.sequence_id, issue2.sequence_id], {status_id: 4}, @project)

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

    document.update_attribute(:name, 'Document update')
    journal_creation_document = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document.id, 'Document', Journal::ACTION_CREATE)
    journal_document = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document.id, 'Document', Journal::ACTION_UPDATE)
    details_document = journal_document.details
    assert journal_creation_document
    assert journal_document
    assert_equal 1, details_document.count

    Journalizable::bulk_delete_dependent([issue1.id, issue2.id], 'Issue')

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_issue1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_issue1.reload }
    assert_not details_issue1[0]
    assert_not details_issue1[1]

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_issue2.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_issue2.reload }
    assert_not details_issue2[0]
    assert_not details_issue2[1]

    assert journal_creation_document.reload
    assert journal_document.reload
    assert_equal 1, details_document.count
  end

  test 'it create a journal when issue is deleted' do
    issue1 = Issue.create(tracker_id: 1, subject: 'This is my issue subject', status_id: '8', project_id: 1, done: 50)
    issue1.destroy
    journals_count = Journal.where(journalizable_type: 'Issue', journalizable_id: issue1.id).count
    assert_equal 1, journals_count
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue1.id, 'Issue', Journal::ACTION_DELETE)
    assert journal
    assert_equal 'This is my issue subject', journal.journalizable_identifier
  end

  test "it does not create a journal when only an excluded attributes has changed" do
    @issue.update_attribute(:description, 'My description')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert_not journal
  end

  test "it does not create a journal when attribute has not changed" do
    @issue.update_attribute(:subject, 'Issue creation')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', Journal::ACTION_UPDATE)
    assert_not journal
  end
end