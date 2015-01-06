require 'test_helper'
require_relative 'magic_filter_test_expected_results'
class MagicFilterTest < ActiveSupport::TestCase
  include IssuesHelper
  include RORganizeTest::MagicFilterTestExpectedResults

  def issue_find(hash)
    Issue.where(Issue.conditions_string(hash)+' 1 = 1').eager_load([:tracker, :version, :assigned_to, :category, :attachments, status: [:enumeration]]).order('issues.id ASC').collect { |issue| issue.id }
  end

  #Generic assertion method for all cases
  def assert_cases(cases, expectations, text)
    i = 0
    cases.each do |test_case|
      assert_equal(expectations[i], issue_find(test_case), text[i])
      i += 1
    end
  end

  def test_subject_filter
    hash = {'subject' => {'operator' => 'contains', 'value' => 'me'}}
    hash1 = {'subject' => {'operator' => 'contains', 'value' => 'Issue'}}
    hash2 = {'subject' => {'operator' => 'not_contains', 'value' => 'p'}}
    cases = [hash, hash1, hash2]
    expectations = [SUBJECT_CONTAINS_ME, SUBJECT_CONTAINS_ISSUE, SUBJECT_NOT_CONTAINS_P]
    text = ['When contains me', 'When subject contains Issue', 'When subject not contains any p']
    assert_cases(cases, expectations, text)
  end

  def test_author_filter
    hash = {'author' => {'operator' => 'equal', 'value' => ['4']}}
    hash1 = {'author' => {'operator' => 'equal', 'value' => ['1']}}
    hash2 = {'author' => {'operator' => 'different', 'value' => ['4']}}
    hash3 = {'author' => {'operator' => 'different', 'value' => ['1']}}
    hash4 = {'author' => {'operator' => 'different', 'value' => %w(1 4)}}
    hash5 = {'author' => {'operator' => 'equal', 'value' => %w(1 4)}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5]
    expectations = [AUTHOR_EQUAL_4, AUTHOR_EQUAL_1, AUTHOR_DIFF_4_OR_NIL, AUTHOR_DIFF_1_OR_NIL, AUTHOR_DIFF_1_AND_4_OR_NIL, AUTHOR_EQUAL_1_OR_4]
    text = ['When author id is 4', 'When author id is 1', 'When author id <> 4', 'When author id <> 1', 'When author id <> 1,4', 'When author id = 1 or 4']
    assert_cases(cases, expectations, text)
  end

  def test_assigned_filter
    hash = {'assigned_to' => {'operator' => 'equal', 'value' => ['4']}}
    hash1 = {'assigned_to' => {'operator' => 'equal', 'value' => ['1']}}
    hash2 = {'assigned_to' => {'operator' => 'different', 'value' => ['4']}}
    hash3 = {'assigned_to' => {'operator' => 'different', 'value' => ['1']}}
    hash4 = {'assigned_to' => {'operator' => 'different', 'value' => %w(1 4)}}
    hash5 = {'assigned_to' => {'operator' => 'equal', 'value' => %w(1 4)}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5]
    expectations = [ASSIGNED_TO_EQUAL_4, ASSIGNED_TO_EQUAL_1, ASSIGNED_TO_DIFF_4_OR_NIL, ASSIGNED_TO_DIFF_1_OR_NIL, ASSIGNED_TO_DIFF_1_AND_4_OR_NIL, ASSIGNED_TO_EQUAL_1_OR_4]
    text = ['When assigned_to id is 4', 'When assigned to = 1', 'When assigned_to id <> 4', 'When assigned_to id <> 1', 'When assigned_to id <> 1,4', 'When assigned_to id = 1,4']
    assert_cases(cases, expectations, text)
  end

  def test_tracker_filter
    hash = {'tracker' => {'operator' => 'equal', 'value' => %w(1 2)}}
    hash1 = {'tracker' => {'operator' => 'equal', 'value' => ['1']}}
    hash2 = {'tracker' => {'operator' => 'equal', 'value' => ['2']}}
    hash3 = {'tracker' => {'operator' => 'different', 'value' => %w(1 2)}}
    hash4 = {'tracker' => {'operator' => 'different', 'value' => ['1']}}
    hash5 = {'tracker' => {'operator' => 'different', 'value' => ['2']}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5]
    expectations = [TRACKER_EQUAL_1_OR_2, TRACKER_EQUAL_1, TRACKER_EQUAL_2, TRACKER_DIFF_1_AND_2_OR_NIL, TRACKER_DIFF_1_OR_NIL, TRACKER_DIFF_2_OR_NIL]
    text = ['When tracker is 1 OR 2', 'When tracker is 1', 'When tracker is 2', 'When tracker is different 1 AND 2', 'When tracker is different 1', 'When tracker is different 2']
    assert_cases(cases, expectations, text)
  end

  def test_status_filter
    hash = {'status' => {'operator' => 'equal', 'value' => %w(1 2 3)}}
    hash1 = {'status' => {'operator' => 'different', 'value' => %w(1 2 3)}}
    hash2 = {'status' => {'operator' => 'equal', 'value' => ['1']}}
    hash3 = {'status' => {'operator' => 'different', 'value' => ['1']}}
    hash4 = {'status' => {'operator' => 'different', 'value' => %w(1 6 7)}}
    hash5 = {'status' => {'operator' => 'equal', 'value' => ['4']}}
    hash6 = {'status' => {'operator' => 'different', 'value' => ['4']}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5, hash6]
    expectations = [STATUS_EQUAL_1_OR_2_OR_3, STATUS_DIFF_1_AND_2_AND_3_OR_NIL, STATUS_EQUAL_1, STATUS_DIFF_1_OR_NIL, STATUS_DIFF_1_AND_6_AND_7_OR_NIL, STATUS_EQUAL_4, STATUS_DIFF_4_OR_NIL]
    text = ['When status is 1 OR 2 OR 3', 'When status is not 1 AND 2 AND 3', 'When status is 1', 'When status is not 1', 'When status is not 1 AND 6 AND 7', 'When status is 4',
            'When status is not 4']
    assert_cases(cases, expectations, text)
  end

  def test_version_filter
    hash = {'version' => {'operator' => 'equal', 'value' => %w(2 1)}}
    hash1 = {'version' => {'operator' => 'equal', 'value' => %w(4 2 1)}}
    hash2 = {'version' => {'operator' => 'different', 'value' => %w(4 2 1)}}
    hash3 = {'version' => {'operator' => 'different', 'value' => %w(2 1)}}
    hash4 = {'version' => {'operator' => 'equal', 'value' => ['1']}}
    hash5 = {'version' => {'operator' => 'different', 'value' => ['1']}}
    hash6 = {'version' => {'operator' => 'equal', 'value' => ['2']}}
    hash7 = {'version' => {'operator' => 'different', 'value' => ['2']}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5, hash6, hash7]
    expectations = [VERSION_EQUAL_1_OR_2, VERSION_EQUAL_1_OR_2_OR_4, VERSION_DIFF_1_AND_2_AND_4_OR_NIL,
                    VERSION_DIFF_1_AND_2_OR_NIL, VERSION_EQUAL_1, VERSION_DIFF_1_OR_NIL, VERSION_EQUAL_2, VERSION_DIFF_2_OR_NIL]
    text = ['When version is 1 OR 2', 'When version is 1 OR 2 OR 4', 'When version is not 1 AND  2 AND 4', 'When version is not 1 AND  2', 'When version is 1', 'When version is not 1',
            'When version is not 4', 'When version is 2', 'When version is not 2']
    assert_cases(cases, expectations, text)
  end

  def test_created_at_filter
    hash = {'created_at' => {'operator' => 'equal', 'value' => '2012-08-03'}}
    hash1 = {'created_at' => {'operator' => 'superior', 'value' => '2013-04-22'}}
    hash2 = {'created_at' => {'operator' => 'inferior', 'value' => '2012-09-08'}}
    hash3 = {'created_at' => {'operator' => 'equal', 'value' => '2012-11-10'}}
    hash4 = {'created_at' => {'operator' => 'equal', 'value' => '2012-10-23'}}

    cases = [hash, hash1, hash2, hash3, hash4]
    expectations = [CREATED_AT_EQUAL_2012_08_03, CREATED_AT_SUP_2013_04_22, CREATED_AT_INF_2012_09_08,
                    CREATED_AT_EQUAL_2012_11_10, CREATED_AT_EQUAL_2012_10_23]
    text = ['When created = 2012-08-03', 'When created >= 2013-04-22', 'When created <= 2012-09-08 ', 'When created = 2012-11-10', 'When created = 2012-10-23']
    assert_cases(cases, expectations, text)
  end

  def test_two_filter
    hash = {'done' => {'operator' => 'inferior', 'value' => ['80']}, 'category' => {'operator' => 'equal', 'value' => ['1']}}
    hash1 = {'done' => {'operator' => 'inferior', 'value' => ['80']}, 'category' => {'operator' => 'equal', 'value' => %w(1 2)}}
    hash2 = {'done' => {'operator' => 'inferior', 'value' => ['80']}, 'category' => {'operator' => 'different', 'value' => %w(1 2)}}
    hash3 = {'created_at' => {'operator' => 'inferior', 'value' => '2012-11-22'}, 'assigned_to' => {'operator' => 'different', 'value' => ['1']}}
    hash4 = {'created_at' => {'operator' => 'inferior', 'value' => '2012-11-22'}, 'assigned_to' => {'operator' => 'equal', 'value' => %w(1 4)}}
    hash5 = {'status' => {'operator' => 'equal', 'value' => %w(1 4)}, 'done' => {'operator' => 'inferior', 'value' => ['50']}}
    hash6 = {'status' => {'operator' => 'equal', 'value' => %w(1 4)}, 'done' => {'operator' => 'superior', 'value' => ['50']}}
    hash7 = {'status' => {'operator' => 'different', 'value' => %w(1 4)}, 'done' => {'operator' => 'superior', 'value' => ['50']}}
    hash8 = {'status' => {'operator' => 'different', 'value' => %w(1 4)}, 'done' => {'operator' => 'inferior', 'value' => ['50']}}

    cases = [hash, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8]
    expectations = [DONE_INF_80_CATEGORY_EQUAL_1, DONE_INF_80_CATEGORY_EQUAL_1_OR_2, DONE_INF_80_CATEGORY_DIFF_1_AND_2_OR_NIL, CREATED_AT_INF_2012_11_22_ASSIGNED_DIFF_1_OR_NIL,
                    CREATED_AT_INF_2012_11_22_ASSIGNED_EQUAL_1_OR_4, STATUS_EQUAL_1_OR_4_DONE_INF_50, STATUS_EQUAL_1_OR_4_DONE_SUP_50, STATUS_DIFF_1_AND_4_OR_NIL_DONE_SUP_50,
                    STATUS_DIFF_1_AND_4_OR_NIL_DONE_INF_50]
    text = ['When done <= 80 AND category id = 1', 'When done <= 80 AND (category id = 1 OR category id = 2)', 'When done <= 80 AND (category id <> 1 AND category id <> 2)',
            'When created_at <= 2012-11-22 AND (assigned id <> 1)', 'When created_at <= 2012-11-22 AND (assigned id = 1 OR assigned to = 4)', 'When status equal 1,4 AND done <= 50',
            'When status equal 1,4 AND done >= 50', 'When status different 1,4 AND done >= 50', 'When status different 1,4 AND done <= 50']
    assert_cases(cases, expectations, text)
  end

  def test_three_filter
    hash = {'done' => {'operator' => 'equal', 'value' => ['100']}, 'assigned_to' => {'operator' => 'different', 'value' => ['4']}, 'tracker' => {'operator' => 'equal', 'value' => ['1']}}
    hash1 = {'status' => {'operator' => 'equal', 'value' => ['4']}, 'version' => {'operator' => 'equal', 'value' => %w(2 4)}, 'category' => {'operator' => 'different', 'value' => %w(2 3)}}

    cases = [hash, hash1]
    expectations = [DONE_EQUAL_100_ASSIGNED_DIFF_1_OR_NIL_TRACKER_EQUAL_1, STATUS_EQUAL_4_VERSION_EQUAL_1_OR_4_CATEGORY_DIFF_2_AND_3_OR_NIL]
    text = ['When done = 100 AND assigned to <> 4 AND tracker = 1', 'When status_id = 4 AND (version_id = 2 OR version_id = 4) AND (category_id <> 2 AND category_id <> 3 OR category_id IS NULL)']
    assert_cases(cases, expectations, text)
  end
end
