# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issue_test.rb
# require 'test/unit'
require 'test_helper'
class DocumentTest < ActiveSupport::TestCase
  include ActiveRecord::ConnectionAdapters::Quoting

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end

  test 'Filtered attributes' do
    expectation = [%w(Name name), %w(Version version), %w(Category category), ['Created at', 'created_at'], ['Updated at', 'updated_at']]
    actual = Document.filtered_attributes
    assert_match_array expectation, actual
  end

  test 'attributes_formalized_names' do
    expectation = ['Name', 'Description', 'Version', 'Category', 'Project', 'Created at', 'Updated at', 'Comments count']
    actual = Document.attributes_formalized_names
    assert_match_array expectation, actual
  end

  test 'permit attributes should contains' do
    expectation = [:name, :description, :version_id, :category_id,
                   {new_attachment_attributes: Attachment.permit_attributes},
                   {edit_attachment_attributes: Attachment.permit_attributes}]
    actual = Document.permit_attributes
    assert_match_array expectation, actual
  end

  test 'caption should be equal to name' do
    name = 'Hello'
    document = Document.new(name: name)
    assert_equal name, document.caption
    assert_equal name, document.name
  end

  test 'permit bulk edit attributes should contains' do
    expectation = [:version_id, :category_id]
    actual = Document.permit_bulk_edit_values
    assert_match_array expectation, actual
  end

  test 'it has an author' do
    document = Document.create(name: 'Helllo')

    assert_equal User.current, document.author

    document.name = 'Hello'
    document.save
    assert_equal User.current, document.author

    User.current = users(:users_002)
    document = Document.create(name: 'Helllo')
    assert_equal users(:users_002), document.author
  end

  test 'it build a condition clause to select documents with category 1' do
    actual = Document.conditions_string({'category' => {'operator' => 'equal', 'value' => ['1']}})

    if is_mysql?
      expected = '(documents.category_id <=> \'1\' ) AND'
    elsif is_sqlite?
      expected = '(documents.category_id IS \'1\' ) AND'
    end

    assert_equal expected, actual
  end

  test 'it build a condition clause to select documents with no category' do
    actual = Document.conditions_string({'category' => {'operator' => 'equal', 'value' => ['NULL']}})
    expected = '(documents.category_id IS NULL ) AND'
    assert_equal expected, actual
  end

  test 'it build a condition clause to select documents with name hello' do
    actual = Document.conditions_string({'name' => {'operator' => 'contains', 'value' => 'hello'}})
    expected = 'documents.name LIKE "%hello%" AND'
    assert_equal expected, actual
  end

  test 'it build a condition clause to select documents with name hello and category 1' do
    actual = Document.conditions_string({'name' => {'operator' => 'contains', 'value' => 'hello'},
                                         'category' => {'operator' => 'equal', 'value' => ['1']}})

    if is_mysql?
      expected = 'documents.name LIKE "%hello%" AND (documents.category_id <=> \'1\' ) AND'
    elsif is_sqlite?
      expected = 'documents.name LIKE "%hello%" AND (documents.category_id IS \'1\' ) AND'
    end

    assert_equal expected, actual
  end

  test 'it build a condition clause to select documents created on 2015 01 07' do
    actual = Document.conditions_string({'created_at' => {'operator' => 'equal', 'value' => '2015-01-07'}})

    if is_mysql?
      expected = 'DATE_FORMAT(documents.created_at,\'%Y-%m-%d\') <=> \'2015-01-07\' AND'
    elsif is_sqlite?
      expected = 'strftime(\'%Y-%m-%d\', documents.created_at) IS \'2015-01-07\' AND'
    end

    assert_equal expected, actual
  end

  test 'it load all project 666 documents' do
    document1 = Document.create(name: 'hello', project_id: 666)
    document2 = Document.create(name: 'hello1', project_id: 666)
    document3 = Document.create(name: 'hello2', project_id: 666)
    documents = []
    documents << document1 << document2 << document3
    assert_equal documents, Document.paginated_documents_method(1, '', 'id ASC', 100, 666)
    assert_equal documents, Document.prepare_paginated(1, 100, 'id ASC', '', 666)

    assert_equal documents.reverse, Document.paginated_documents_method(1, '', 'name DESC', 100, 666)
    assert_equal documents.reverse, Document.prepare_paginated(1, 100, 'name DESC', '', 666)

    document_conditions_string = Document.conditions_string({'name' => {'operator' => 'contains', 'value' => 'hello'}})
    assert_equal documents, Document.paginated_documents_method(1, document_conditions_string, 'documents.id ASC', 100, 666)
    assert_equal documents, Document.prepare_paginated(1, 100, 'documents.id ASC', document_conditions_string, 666)
  end

  test 'it should not save a document without a valid name' do
    doc = Document.new(name: '')
    assert_not doc.save, 'Saved with an empty name'

    doc = Document.new
    assert_not doc.save, 'Saved with an empty name'

    doc = Document.new(name: 'a')
    assert_not doc.save, 'Saved with a single char name'

    doc = Document.new(name: generate_string_of_length(256))
    assert_not doc.save, 'Saved with more than 255 char name'

    doc = Document.new(name: 'qwertz')
    assert doc.save, doc.errors.messages
  end

end