# Author: Nicolas Meylan
# Date: 19.01.15 10:00
# Encoding: UTF-8
# File: document_bulk_editable_test.rb
require 'test_helper'

class DocumentBulkEditableTest < ActiveSupport::TestCase

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

  test 'it create a journal with details on bulk edition' do
    category1 = Category.create(name: 'Deployment')
    category2 = Category.create(name: 'CI')

    document1 = Document.create(name: 'Document creation', project_id: @project.id, category_id: category1.id)
    document2 = Document.create(name: 'Document creation', project_id: @project.id)
    document3 = Document.create(name: 'Document creation', project_id: @project.id, category_id: category2.id)
    document_ids = [document1.sequence_id, document2.sequence_id, document3.sequence_id]

    Document.bulk_edit(document_ids, {'category_id' => category2.id}, @project)
    journal_document1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document1.id, 'Document', Journal::ACTION_UPDATE)
    journal_document2 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document2.id, 'Document', Journal::ACTION_UPDATE)
    journal_document3 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(document3.id, 'Document', Journal::ACTION_UPDATE)

    assert journal_document1
    assert journal_document2
    assert_not journal_document3 # has not changed

    details_document1 = journal_document1.details
    details_document2 = journal_document2.details

    assert_equal 1, details_document1.count
    assert_equal 1, details_document2.count

    assert_equal 'category_id', details_document1.first.property_key
    assert_equal 'Deployment', details_document1.first.old_value
    assert_equal 'CI', details_document1.first.value

    assert_equal 'category_id', details_document2.first.property_key
    assert_equal '', details_document2.first.old_value
    assert_equal 'CI', details_document2.first.value
  end
end