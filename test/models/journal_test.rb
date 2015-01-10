# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: journal_test.rb
require 'test_helper'

class JournalTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  test "scope activities" do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 20))
    journal1 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))
    journal2 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 22))
    journal3 = Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 23))

    date_range = (Date.new(2012, 10, 19))..(Date.new(2012, 10, 23))
    expected = [journal, journal1, journal2, journal3]
    actual = Journal.activities_method("project_id = #{666}", date_range, 1, ['Issue'])
    assert_match_array expected, actual

    date_range = (Date.new(2012, 10, 19))..(Date.new(2012, 10, 22))
    expected = [journal, journal1, journal2]
    actual = Journal.activities_method("project_id = #{666}", date_range, 1, ['Issue'])
    assert_match_array expected, actual
  end

  test 'class build a date range for history display' do
    date = Date.new(2001, 2, 3)
    assert_equal (Date.new(2001, 1, 28))..(Date.new(2001, 2, 4)), Journal.build_date_range(date, :ONE_WEEK)
    assert_equal (Date.new(2001, 2, 1))..(Date.new(2001, 2, 4)), Journal.build_date_range(date, :THREE_DAYS)
    assert_equal (Date.new(2001, 2, 3))..(Date.new(2001, 2, 4)), Journal.build_date_range(date, :ONE_DAY)
    assert_equal (Date.new(2001, 1, 4))..(Date.new(2001, 2, 4)), Journal.build_date_range(date, :ONE_MONTH)
  end

  test 'scope that eager load all journals for issue type for a given time range.' do
    date1 = Time.new(2001, 2, 2, 13, 30, 0)
    date2 = Time.new(2001, 2, 1, 14, 30, 0)
    date3 = Time.new(2001, 2, 3, 14, 30, 0)
    date1_out_of_range = Time.new(2001, 2, 4, 14, 30, 0)
    date2_out_of_range = Time.new(2001, 1, 31, 14, 30, 0)
    dates = []
    dates << date1 << date2 << date3 << date1_out_of_range << date2_out_of_range
    journals = dates.collect do |date|
      Journal.create(journalizable_type: 'Issue', journalizable_id: 1, action_type: 'created',
                     project_id: 666, journalizable_identifier: 'aa', created_at: date)
    end

    expected_result = journals[0, 3]

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array expected_result, Journal.activities_eager_load(['Issue'], period, range_end_date, 'journals.project_id = 666').to_a

    range_end_date = Date.new(2001, 2, 4)
    period = :ONE_WEEK
    assert_match_array journals, Journal.activities_eager_load(['Issue'], period, range_end_date, 'journals.project_id = 666').to_a
  end

  test 'scope that eager load all journals for a given issue' do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'created',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))
    journal1 = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'updated',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 22))
    journal2 = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'updated',
                   project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 23))

    assert_match_array [journal, journal1, journal2], Journal.journalizable_activities(666, 'Issue')
  end

  test 'it should prepare detail insertion when the journal type is updated' do
    params = {done: [0, 100], status_id: [1, 3]}
    expectation = [{property: 'Done', property_key: :done, old_value: 0, value: 100},
                   {property: 'Status', property_key: :status_id, old_value: 'New', value: 'Closed'}]
    assert_equal expectation, Journal.prepare_detail_insertion(Issue, params)

    params = {assigned_to_id: [nil, 1]}
    expectation = [{property: 'Assigned to', property_key: :assigned_to_id, old_value: nil, value: 'Nicolas Meylan'}]
    assert_equal expectation, Journal.prepare_detail_insertion(Issue, params)

    params = {assigned_to_id: [1, nil]}
    expectation = [{property: 'Assigned to', property_key: :assigned_to_id, old_value: 'Nicolas Meylan', value: nil}]
    assert_equal expectation, Journal.prepare_detail_insertion(Issue, params)
  end

  test 'it make attribute name readable' do
    attribute_name_expectation_hash = {status_id: 'Status', assigned_to_id: 'Assigned to', subject: 'Subject', done: 'Done', created_at: 'Created at'}

    attribute_name_expectation_hash.each do |attribute_name, expectation|
      assert_equal expectation, Journal.make_attribute_readable(attribute_name)
    end
  end

  test 'it has a polymorphic identifier to retrieve the belonging object' do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'created',
                             project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))
    assert_equal :Issue_666, journal.polymorphic_identifier
  end

  test 'it has many details and should destroy them when the journal is destroyed' do
    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'created',
                             project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))
    details = []
    details << JournalDetail.create(journal_id: journal.id, property: 'Assigned to', property_key: :assigned_to_id,
                         old_value: nil, value: 'Nicolas Meylan')
    details << JournalDetail.create(journal_id: journal.id, property: 'Assigned to', property_key: :assigned_to_id,
                         old_value: 'Nicolas Meylan', value: nil)
    details << JournalDetail.create(journal_id: journal.id, property: 'Done', property_key: :done, old_value: 0, value: 100)
    
    journal.reload
    assert_equal details, journal.details
    assert_equal details, JournalDetail.where(journal_id: journal.id)

    journal.destroy
    assert_equal [], JournalDetail.where(journal_id: journal.id)
  end
end