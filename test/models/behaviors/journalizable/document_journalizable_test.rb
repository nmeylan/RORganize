# Author: Nicolas Meylan
# Date: 16.01.15 16:20
# Encoding: UTF-8
# File: document_journalizable_test.rb
require 'test_helper'

class DocumentJournalizableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @document = Document.create(name: 'Document creation', project_id: @project.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end
  
  test "it create a journal when document has been created" do
    journal = Journal.find_by_journalizable_id_and_journalizable_type(@document.id, 'Document')
    assert Journal::ACTION_CREATE, journal.action_type
  end

  test "it create a journal when subject is updated" do
    @document.update_attribute(:name, 'Document update')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 1, details.count

    subject_update_detail = details.first
    assert_equal 'name', subject_update_detail.property_key
    assert_equal 'Document creation', subject_update_detail.old_value
    assert_equal 'Document update', subject_update_detail.value
  end

  test 'it create a journal when an attribute and an excluded one have changed' do
    @document.update_attributes({name: 'Document update', description: 'My description'})
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 1, details.count

    subject_update_detail = details.first
    assert_equal 'name', subject_update_detail.property_key
    assert_equal 'Document creation', subject_update_detail.old_value
    assert_equal 'Document update', subject_update_detail.value
  end

  test 'it create a journal with a detail for each updated attributes' do
    version = Version.create(name: 'Release 1.0', start_date: '2012-12-01', project_id: @project.id)
    @document.update_attributes({name: 'Document update', version_id: version.id})
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal

    assert_equal 2, details.count

    subject_update_detail = details.first
    assert_equal 'name', subject_update_detail.property_key
    assert_equal 'Document creation', subject_update_detail.old_value
    assert_equal 'Document update', subject_update_detail.value

    done_update_detail = details[1]
    assert_equal 'version_id', done_update_detail.property_key
    assert_equal nil, done_update_detail.old_value
    assert_equal 'Release 1.0', done_update_detail.value
  end



  test 'it delete all journals and details when document is deleted' do
    document1 = Document.create(name: 'Document creation', project_id: @project.id)
    document1.update_attribute(:version_id, 4)
    journal_creation = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_CREATE)
    assert journal_creation
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_UPDATE)
    details = journal.details
    assert journal
    assert_equal 1, details.count

    document1.destroy
    assert_raise(ActiveRecord::RecordNotFound) { journal_creation.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal.reload }
    assert_not details[0]
    assert_not details[1]
  end

  test 'it delete all journals and details when bulk delete dependent is called' do
    document1 = Document.create(name: 'Document creation', project_id: @project.id)
    document2 = Document.create(name: 'Document creation', project_id: @project.id)
    issue = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '8', project_id: 1, done: 50)
    Document.bulk_edit([document1.sequence_id, document2.sequence_id], {version_id: 4}, @project)

    journal_creation_document1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_CREATE)
    journal_document1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_UPDATE)
    details_document1 = journal_document1.details
    assert journal_creation_document1
    assert journal_document1
    assert_equal 1, details_document1.count

    journal_creation_document2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document2.id, 'Document', Journal::ACTION_CREATE)
    journal_document2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document2.id, 'Document', Journal::ACTION_UPDATE)
    details_document2 = journal_document2.details
    assert journal_creation_document2
    assert journal_document2
    assert_equal 1, details_document2.count

    issue.update_attribute(:status_id, 4)
    journal_creation_document = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue.id, 'Issue', Journal::ACTION_CREATE)
    journal_document = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue.id, 'Issue', Journal::ACTION_UPDATE)
    details_document = journal_document.details
    assert journal_creation_document
    assert journal_document
    assert_equal 2, details_document.count

    Journalizable::bulk_delete_dependent([document1.id, document2.id], 'Document')

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_document1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_document1.reload }
    assert_not details_document1[0]
    assert_not details_document1[1]

    assert_raise(ActiveRecord::RecordNotFound) { journal_creation_document2.reload }
    assert_raise(ActiveRecord::RecordNotFound) { journal_document2.reload }
    assert_not details_document2[0]
    assert_not details_document2[1]

    assert journal_creation_document.reload
    assert journal_document.reload
    assert_equal 2, details_document.count
  end

  test 'it create a journal when document is deleted' do
    document1 = Document.create(name: 'This is my document name', project_id: @project.id)
    document1.destroy
    journals_count = Journal.where(journalizable_type: 'Document', journalizable_id: document1.id).count
    assert_equal 1, journals_count
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_DELETE)
    assert journal
    assert_equal 'This is my document name', journal.journalizable_identifier
  end

  test "it does not create a journal when only an excluded attributes has changed" do
    @document.update_attribute(:description, 'My description')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', Journal::ACTION_UPDATE)
    assert_not journal
  end

  test "it does not create a journal when attribute has not changed" do
    @document.update_attribute(:name, 'Document creation')
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', Journal::ACTION_UPDATE)
    assert_not journal
  end
end