require 'test_helper'
require 'unit/magic_filter_test_expected_results'
class MagicFilterTest < ActiveSupport::TestCase
  include IssuesHelper
  include RORganizeTest::MagicFilterTestExpectedResults

  def test_subject_filter
    hash = {'subject' =>{'operator' => 'contains', 'value' => 'me'}}
    hash1 = {'subject' =>{'operator' => 'contains', 'value' => 'Issue'}}
    hash2 = {'subject' =>{'operator' => 'not contains', 'value' => 'p'}}

    assert_equal(SUBJECT_CONTAINS_ME, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'contains me')
    assert_equal(SUBJECT_CONTAINS_ISSUE, Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}, 'When subject contains Issue')
    assert_equal(SUBJECT_NOT_CONTAINS_P, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}), 'When subject not contains any p')
  end

  def test_author_filter
    hash = {'author' =>{'operator' => 'equal', 'value' =>['4']}}
    hash1 = {'author' =>{'operator' => 'equal', 'value' =>['1']}}
    hash2 = {'author' =>{'operator' => 'different', 'value' =>['4']}}
    hash3 = {'author' =>{'operator' => 'different', 'value' =>['1']}}
    hash4 = {'author' =>{'operator' => 'different', 'value' => %w(1 4)}}
    hash5 = {'author' =>{'operator' => 'equal', 'value' => %w(1 4)}}

    assert_equal(AUTHOR_EQUAL_4, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When author id is 4')
    assert_equal(AUTHOR_EQUAL_1, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When author id is 1')
    assert_equal(AUTHOR_DIFF_4_OR_NIL, ((Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}).sort), 'When author id <> 4')
    assert_equal(AUTHOR_DIFF_1_OR_NIL, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}), 'When author id <> 1')
    assert_equal(AUTHOR_DIFF_1_AND_4_OR_NIL, (Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}), 'When author id <> 1,4')
    assert_equal(AUTHOR_EQUAL_1_OR_4, (Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}), 'When author id = 1 or 4')
  end

  def test_assigned_filter
    hash = {'assigned_to' =>{'operator' => 'equal', 'value' =>['4']}}
    hash1 = {'assigned_to' =>{'operator' => 'equal', 'value' =>['1']}}
    hash2 = {'assigned_to' =>{'operator' => 'different', 'value' =>['4']}}
    hash3 = {'assigned_to' =>{'operator' => 'different', 'value' =>['1']}}
    hash4 = {'assigned_to' =>{'operator' => 'different', 'value' => %w(1 4)}}
    hash5 = {'assigned_to' =>{'operator' => 'equal', 'value' => %w(1 4)}}

    assert_equal(ASSIGNED_TO_EQUAL_4, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When assigned_to id is 4')
    assert_equal(ASSIGNED_TO_EQUAL_1, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When assigned to = 1')
    assert_equal(ASSIGNED_TO_DIFF_4_OR_NIL, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}).sort, 'When assigned_to id <> 4')
    assert_equal(ASSIGNED_TO_DIFF_1_OR_NIL, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}).sort, 'When assigned_to id <> 1')
    assert_equal(ASSIGNED_TO_DIFF_1_AND_4_OR_NIL, (Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}).sort, 'When assigned_to id <> 1,4')
    assert_equal(ASSIGNED_TO_EQUAL_1_OR_4,(Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}), 'When assigned_to id = 1,4')
  end

  def test_tracker_filter
    hash = {'tracker' =>{'operator' => 'equal', 'value' => %w(1 2)}}
    hash1 = {'tracker' =>{'operator' => 'equal', 'value' =>['1']}}
    hash2 = {'tracker' =>{'operator' => 'equal', 'value' =>['2']}}
    hash3 = {'tracker' =>{'operator' => 'different', 'value' => %w(1 2)}}
    hash4 = {'tracker' =>{'operator' => 'different', 'value' =>['1']}}
    hash5 = {'tracker' =>{'operator' => 'different', 'value' =>['2']}}

    assert_equal(TRACKER_EQUAL_1_OR_2,(Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is 1 OR 2')
    assert_equal(TRACKER_EQUAL_1, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is 1')
    assert_equal(TRACKER_EQUAL_2, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is 2')
    assert_equal(TRACKER_DIFF_1_AND_2_OR_NIL, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is different 1 AND 2')
    assert_equal(TRACKER_DIFF_1_OR_NIL,(Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is different 1')
    assert_equal(TRACKER_DIFF_2_OR_NIL,(Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}), 'When tracker is different 2')
  end

  def test_status_filter
    hash = {'status' =>{'operator' => 'equal', 'value' => %w(1 2 3)}}
    hash1 = {'status' =>{'operator' => 'different', 'value' => %w(1 2 3)}}
    hash2 = {'status' =>{'operator' => 'equal', 'value' =>['1']}}
    hash3 = {'status' =>{'operator' => 'different', 'value' =>['1']}}
    hash4 = {'status' =>{'operator' => 'different', 'value' => %w(1 6 7)}}
    hash5 = {'status' =>{'operator' => 'equal', 'value' =>['4']}}
    hash6 = {'status' =>{'operator' => 'different', 'value' =>['4']}}

    assert_equal(STATUS_EQUAL_1_OR_2_OR_3, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When status is 1 OR 2 OR 3')
    assert_equal(STATUS_DIFF_1_AND_2_AND_3_OR_NIL, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1 AND 2 AND 3')
    assert_equal(STATUS_EQUAL_1, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}), 'When status is 1')
    assert_equal(STATUS_DIFF_1_OR_NIL, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1')
    assert_equal(STATUS_DIFF_1_AND_6_AND_7_OR_NIL, (Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1 AND 6 AND 7')
    assert_equal(STATUS_EQUAL_4, (Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}), 'When status is 4')
    assert_equal(STATUS_DIFF_4_OR_NIL, (Issue.where(issues_filter(hash6)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 4')
  end

  def test_version_filter
    hash = {'version' =>{'operator' => 'equal', 'value' => %w(2 1)}}
    hash1 = {'version' =>{'operator' => 'equal', 'value' => %w(4 2 1)}}
    hash2 = {'version' =>{'operator' => 'different', 'value' => %w(4 2 1)}}
    hash3 = {'version' =>{'operator' => 'different', 'value' => %w(2 1)}}
    hash4 = {'version' =>{'operator' => 'equal', 'value' =>['1']}}
    hash5 = {'version' =>{'operator' => 'different', 'value' =>['1']}}
    hash6 = {'version' =>{'operator' => 'equal', 'value' =>['2']}}
    hash7 = {'version' =>{'operator' => 'different', 'value' =>['2']}}

    assert_equal(VERSION_EQUAL_1_OR_2, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When status is 1 OR 2')
    assert_equal(VERSION_EQUAL_1_OR_2_OR_4, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When status is 1 OR 2 OR 4')
    assert_equal(VERSION_DIFF_1_AND_2_AND_4_OR_NIL, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1 AND  2 AND 4')
    assert_equal(VERSION_DIFF_1_AND_2_OR_NIL, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1 AND  2')
    assert_equal(VERSION_EQUAL_1, (Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}), 'When status is 1')
    assert_equal(VERSION_DIFF_1_OR_NIL, (Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 1')
    assert_equal(VERSION_EQUAL_2, (Issue.where(issues_filter(hash6)+' 1 = 1').collect{|issue| issue.id}), 'When status is 2')
    assert_equal(VERSION_DIFF_2_OR_NIL, (Issue.where(issues_filter(hash7)+' 1 = 1').collect{|issue| issue.id}), 'When status is not 2')
  end

  def test_created_at_filter
    hash = {'created_at' =>{'operator' => 'equal', 'value' => '2012-08-03'}}
    hash1 = {'created_at' =>{'operator' => 'superior', 'value' => '2013-04-22'}}
    hash2 = {'created_at' =>{'operator' => 'inferior', 'value' => '2012-09-08'}}
    hash3 = {'created_at' =>{'operator' => 'equal', 'value' => '2012-11-10'}}
    hash4 = {'created_at' =>{'operator' => 'equal', 'value' => '2012-10-23'}}

    assert_equal(CREATED_AT_EQUAL_2012_08_03, Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}, 'When created = 2012-08-03')
    assert_equal(CREATED_AT_SUP_2013_04_22, (Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}), 'When created >= 2013-04-22')
    assert_equal(CREATED_AT_INF_2012_09_08, (Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}), 'When created <= 2012-09-08 ')
    assert_equal(CREATED_AT_EQUAL_2012_11_10, (Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}), 'When created = 2012-11-10')
    assert_equal(CREATED_AT_EQUAL_2012_10_23, (Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}), 'When created = 2012-10-23')
  end

  def test_two_filter
    hash = {'done' =>{'operator' => 'inferior', 'value' =>['80']}, 'category' =>{'operator' => 'equal', 'value' =>['1']}}
    hash1 = {'done' =>{'operator' => 'inferior', 'value' =>['80']}, 'category' =>{'operator' => 'equal', 'value' => %w(1 2)}}
    hash2 = {'done' =>{'operator' => 'inferior', 'value' =>['80']}, 'category' =>{'operator' => 'different', 'value' => %w(1 2)}}
    hash3 = {'created_at' =>{'operator' => 'inferior', 'value' => '2012-11-22'}, 'assigned_to' =>{'operator' => 'different', 'value' =>['1']}}
    hash4 = {'created_at' =>{'operator' => 'inferior', 'value' => '2012-11-22'}, 'assigned_to' =>{'operator' => 'equal', 'value' => %w(1 4)}}
    hash5 = {'status' =>{'operator' => 'equal', 'value' => %w(1 4)}, 'done' =>{'operator' => 'inferior', 'value' =>['50']}}
    hash6 = {'status' =>{'operator' => 'equal', 'value' => %w(1 4)}, 'done' =>{'operator' => 'superior', 'value' =>['50']}}
    hash7 = {'status' =>{'operator' => 'different', 'value' => %w(1 4)}, 'done' =>{'operator' => 'superior', 'value' =>['50']}}
    hash8 = {'status' =>{'operator' => 'different', 'value' => %w(1 4)}, 'done' =>{'operator' => 'inferior', 'value' =>['50']}}
    hash9 = {'due_date' =>{'operator' => 'today', 'value' => ''}, 'author' =>{'operator' => 'equal', 'value' =>['1']}}

    assert_equal(DONE_INF_80_CATEGORY_EQUAL_1, (Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}), 'When done <= 80 AND category id = 1')
    assert_equal(DONE_INF_80_CATEGORY_EQUAL_1_OR_2, Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}, 'When done <= 80 AND (category id = 1 OR category id = 2)')
    assert_equal(DONE_INF_80_CATEGORY_DIFF_1_AND_2_OR_NIL, Issue.where(issues_filter(hash2)+' 1 = 1').collect{|issue| issue.id}, 'When done <= 80 AND (category id <> 1 AND category id <> 2)')
    assert_equal(CREATED_AT_INF_2012_11_22_ASSIGNED_DIFF_1_OR_NIL, Issue.where(issues_filter(hash3)+' 1 = 1').collect{|issue| issue.id}, 'When created_at <= 2012-11-22 AND (assigned id <> 1)')
    assert_equal(CREATED_AT_INF_2012_11_22_ASSIGNED_EQUAL_1_OR_4, Issue.where(issues_filter(hash4)+' 1 = 1').collect{|issue| issue.id}, 'When created_at <= 2012-11-22 AND (assigned id = 1 OR assigned to = 4)')
    assert_equal(STATUS_EQUAL_1_OR_4_DONE_INF_50, Issue.where(issues_filter(hash5)+' 1 = 1').collect{|issue| issue.id}, 'When status equal 1,4 AND done <= 50')
    assert_equal(STATUS_EQUAL_1_OR_4_DONE_SUP_50, Issue.where(issues_filter(hash6)+' 1 = 1').collect{|issue| issue.id}, 'When status equal 1,4 AND done >= 50')
    assert_equal(STATUS_DIFF_1_AND_4_OR_NIL_DONE_SUP_50, Issue.where(issues_filter(hash7)+' 1 = 1').collect{|issue| issue.id}, 'When status different 1,4 AND done >= 50')
    assert_equal(STATUS_DIFF_1_AND_4_OR_NIL_DONE_INF_50, Issue.where(issues_filter(hash8)+' 1 = 1').collect{|issue| issue.id}, 'When status different 1,4 AND done <= 50')
  end

  def test_three_filter
    hash = {'done' =>{'operator' => 'equal', 'value' =>['100']}, 'assigned_to' =>{'operator' => 'different', 'value' =>['4']}, 'tracker' =>{'operator' => 'equal', 'value' =>['1']}}
    hash1 = {'status' =>{'operator' => 'equal', 'value' =>['4']}, 'version' =>{'operator' => 'equal', 'value' => %w(2 4)}, 'category' =>{'operator' => 'different', 'value' => %w(2 3)}}

    assert_equal(DONE_EQUAL_100_ASSIGNED_DIFF_1_OR_NIL_TRACKER_EQUAL_1, Issue.where(issues_filter(hash)+' 1 = 1').collect{|issue| issue.id}, 'When done = 100 AND assigned to <> 4 AND tracker = 1')
    assert_equal(STATUS_EQUAL_4_VERSION_EQUAL_1_OR_4_CATEGORY_DIFF_2_AND_3_OR_NIL, Issue.where(issues_filter(hash1)+' 1 = 1').collect{|issue| issue.id}, 'When status_id = 4 AND (version_id = 2 OR version_id = 4) AND (category_id <> 2 AND category_id <> 3 OR category_id IS NULL)')
  end
end
