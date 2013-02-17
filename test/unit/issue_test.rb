class IssueTest < Test::Unit::TestCase
  require 'test_helper'
  def test_subject_filter
    hash = {"subject"=>{"operator"=>"contains", "value"=>"me"}}
    hash1 = {"subject"=>{"operator"=>"contains", "value"=>"Issue"}}
    hash2 = {"subject"=>{"operator"=>"not contains", "value"=>"p"}}
    assert([45,62,97,102].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'contains me')
    assert([9,16,36,37,42,62,77,88].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When subject contains Issue')
    assert([10,12,16,36,39,40,42,45,46,49,51,53,76,83,86,96,101,103,104].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When subject not contains any p')
  end

  def test_author_filter
    hash = {"author"=>{"operator"=>"equal", "value"=>["4"]}}
    hash1 = {"author"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"author"=>{"operator"=>"different", "value"=>["4"]}}
    hash3 = {"author"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"author"=>{"operator"=>"different", "value"=>["1", "4"]}}
    hash5 = {"author"=>{"operator"=>"equal", "value"=>["1", "4"]}}
    assert([104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When author id is 4')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When author id is 1')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When author id <> 4')
    assert([104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When author id <> 1')
    assert([].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When author id <> 1,4')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When author id = 1 or 4')
  end

  def test_assigned_filter
    hash = {"assigned_to"=>{"operator"=>"equal", "value"=>["4"]}}
    hash1 = {"assigned_to"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"assigned_to"=>{"operator"=>"different", "value"=>["4"]}}
    hash3 = {"assigned_to"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"assigned_to"=>{"operator"=>"different", "value"=>["1", "4"]}}
    hash5 = {"assigned_to"=>{"operator"=>"equal", "value"=>["1", "4"]}}
    assert([104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When assigned_to id is 4')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,102,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When assigned to = 1')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When assigned_to id <> 4')
    assert([101,104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When assigned_to id <> 1')
    assert([101].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When assigned_to id <> 1,4')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,102,103,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When assigned_to id = 1,4')
  end

  def test_tracker_filter
    hash = {"tracker"=>{"operator"=>"equal", "value"=>["1", "2"]}}
    hash1 = {"tracker"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"tracker"=>{"operator"=>"equal", "value"=>["2"]}}
    hash3 = {"tracker"=>{"operator"=>"different", "value"=>["1","2"]}}
    hash4 = {"tracker"=>{"operator"=>"different", "value"=>["1"]}}
    hash5 = {"tracker"=>{"operator"=>"different", "value"=>["2"]}}
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103,104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When tracker is 1 OR 2')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,92,96,98,101,103,104].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When tracker is 1')
    assert([88,97,102].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When tracker is 2')
    assert([].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When tracker is different 1 AND 2')
    assert([88,97,102].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When tracker is different 1')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,92,96,98,101,103,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When tracker is different 2')
  end

  def test_status_filter
    hash = {"status"=>{"operator"=>"equal", "value"=>["1", "2", "3"]}}
    hash1 = {"status"=>{"operator"=>"different", "value"=>["1", "2", "3"]}}
    hash2 = {"status"=>{"operator"=>"equal", "value"=>["1"]}}
    hash3 = {"status"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"status"=>{"operator"=>"different", "value"=>["1", "6", "7"]}}
    hash5 = {"status"=>{"operator"=>"equal", "value"=>["4"]}}
    hash6 = {"status"=>{"operator"=>"different", "value"=>["4"]}}
    assert([38,40,44,45,48,49,50,51,52,53,54,55,56,76,83,86,96,98,101,104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When status is 1 OR 2 OR 3')
    assert([9,10,11,12,16,36,37,39,41,42,43,46,47,62,77,88,92,97,102,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When status is not 1 AND 2 AND 3')
    assert([38,40,44,45,48,49,50,51,52,54,55,56,76,83,86,96,101,104].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When status is 1')
    assert([9,10,11,12,16,36,37,39,41,42,43,46,47,53,62,77,88,92,97,98,102,103].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When status is not 1')
    assert([9,10,11,12,16,36,37,39,41,42,43,46,47,53,62,77,88,92,97,98,102,103].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When status is not 1 AND 6 AND 7')
    assert([9,10,11,12,16,36,37,39,41,42,43,46,47,62,77,88,92,97,102,103].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When status is 4')
    assert([38,40,44,45,48,49,50,51,52,53,54,55,56,76,83,86,96,98,101,104].eql?(Issue.filter(hash6).collect{|issue| issue.id}), 'When status is not 4')
  end

  def test_version_filter
    hash = {"version"=>{"operator"=>"equal", "value"=>["2", "1"]}}
    hash1 = {"version"=>{"operator"=>"equal", "value"=>["4","2", "1"]}}
    hash2 = {"version"=>{"operator"=>"different", "value"=>["4","2", "1"]}}
    hash3 = {"version"=>{"operator"=>"different", "value"=>["2", "1"]}}
    hash4 = {"version"=>{"operator"=>"equal", "value"=>["1"]}}
    hash5 = {"version"=>{"operator"=>"different", "value"=>["1"]}}
    hash6 = {"version"=>{"operator"=>"equal", "value"=>["2"]}}
    hash7 = {"version"=>{"operator"=>"different", "value"=>["2"]}}
    assert([9,10,11,12,16,36,41,42,43,103].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When status is 1 OR 2')
    assert([9,10,11,12,16,36,37,39,40,41,42,43,45,46,62,96,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When status is 1 OR 2 OR 4')
    assert([38,44,47,48,49,50,51,52,53,54,55,56,76,77,83,86,88,92,97,98,101,102,104].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When status is not 1 AND  2 AND 4')
    assert([37,38,39,40,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When status is not 1 AND  2')
    assert([9,10,11,12,16,36,41].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When status is 1')
    assert([37,38,39,40,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,103,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When status is not 1')
    assert([42,43,103].eql?(Issue.filter(hash6).collect{|issue| issue.id}), 'When status is 2')
    assert([9,10,11,12,16,36,37,38,39,40,41,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,101,102,104].eql?(Issue.filter(hash7).collect{|issue| issue.id}), 'When status is not 2')
  end

  def test_category_filter
    hash = {"category"=>{"operator"=>"equal", "value"=>["2", "1"]}}
    hash1 = {"category"=>{"operator"=>"equal", "value"=>["3","2", "1"]}}
    hash2 = {"category"=>{"operator"=>"different", "value"=>["3","2", "1"]}}
    hash3 = {"category"=>{"operator"=>"different", "value"=>["2", "1"]}}
    hash4 = {"category"=>{"operator"=>"equal", "value"=>["1"]}}
    hash5 = {"category"=>{"operator"=>"different", "value"=>["1"]}}
    hash6 = {"category"=>{"operator"=>"equal", "value"=>["2"]}}
    hash7 = {"category"=>{"operator"=>"different", "value"=>["2"]}}
    assert([9,10,11,12,16,43,76,83,96,98,103].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When status is 1 OR 2')
    assert([9,10,11,12,16,43,76,83,86,96,98,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When status is 1 OR 2 OR 3')
    assert([36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,52,53,54,55,56,62,77,88,92,97,101,102,104].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When status is not 1 OR 2 OR 3')
    assert([36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,52,53,54,55,56,62,77,86,88,92,97,101,102,104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When status is not 1 OR 2')
    assert([83,98,103].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When status is 1')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,86,88,92,96,97,101,102,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When status is not 1')
    assert([9,10,11,12,16,43,76,96].eql?(Issue.filter(hash6).collect{|issue| issue.id}), 'When status is 2')
    assert([36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,52,53,54,55,56,62,77,83,86,88,92,97,98,101,102,103,104].eql?(Issue.filter(hash7).collect{|issue| issue.id}), 'When status is not 2')
  end

  def test_done_filter
    hash = {"done"=>{"operator"=>"superior", "value"=>["50"]}}
    hash1 = {"done"=>{"operator"=>"inferior", "value"=>["50"]}}
    hash2 = {"done"=>{"operator"=>"equal", "value"=>["100"]}}
    hash3 = {"done"=>{"operator"=>"different", "value"=>["100"]}}
    assert([9,10,11,12,16,36,37,39,41,42,43,45,46,47,55,62,77,88,92,97,102,103].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When done >= 50')
    assert([38,40,44,48,49,50,51,52,53,54,55,56,76,83,86,96,98,101,104].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When done <= 50')
    assert([9,10,11,12,16,36,37,39,42,43,46,47,62,77,88,92,97,102,103].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When done = 100')
    assert([38,40,41,44,45,48,49,50,51,52,53,54,55,56,76,83,86,96,98,101,104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When done <> 100')
  end

  def test_created_at_filter
    hash = {"created_at"=>{"operator"=>"equal", "value"=>"2012-11-09"}}
    hash1 = {"created_at"=>{"operator"=>"superior", "value"=>"2012-11-09"}}
    hash2 = {"created_at"=>{"operator"=>"inferior", "value"=>"2012-09-08"}}
    hash3 = {"created_at"=>{"operator"=>"equal", "value"=>"2012-11-10"}}
    hash4 = {"created_at"=>{"operator"=>"equal", "value"=>"2012-10-23"}}
    assert([104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When created = 2012-11-09')
    assert([104].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When created >= 2012-11-09')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When created <= 2012-11-08 ')
    assert([].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When created = 2012-11-10')
    assert([96,97,98,101,102].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When created = 2012-10-23')
  end

  def test_updated_at_filter
    hash = {"updated_at"=>{"operator"=>"equal", "value"=>"2012-11-09"}}
    hash1 = {"updated_at"=>{"operator"=>"superior", "value"=>"2012-11-09"}}
    hash2 = {"updated_at"=>{"operator"=>"inferior", "value"=>"2012-09-08"}}
    hash3 = {"updated_at"=>{"operator"=>"equal", "value"=>"2012-11-10"}}
    hash4 = {"updated_at"=>{"operator"=>"equal", "value"=>"2012-10-23"}}
    assert([104].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When updated = 2012-11-09')
    assert([104].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When updated >= 2012-11-09')
    assert([9,10,11,12,16,36,42,43].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When updated <= 2012-11-08 ')
    assert([].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When updated = 2012-11-10')
    assert([45,47,77,96,98,101].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When updated = 2012-10-23')
  end

  def test_due_date_filter
    hash = {"due_date"=>{"operator"=>"equal", "value"=>"2012-10-20"}}
    hash1 = {"due_date"=>{"operator"=>"superior", "value"=>"2012-10-09"}}
    hash2 = {"due_date"=>{"operator"=>"inferior", "value"=>"2012-10-19"}}
    hash3 = {"due_date"=>{"operator"=>"today", "value"=>"2012-10-19"}}
    assert([77].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When due_date = 2012-10-20')
    assert([9,77].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When due_date >= 2012-10-09')
    assert([].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When due_date <= 2012-10-19 ')
    assert([9].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When due_date is today ')
  end

  def test_two_filter
    hash = {"done"=>{"operator"=>"inferior", "value"=>["80"]}, "category"=>{"operator"=>"equal", "value"=>["1"]}}
    hash1 = {"done"=>{"operator"=>"inferior", "value"=>["80"]}, "category"=>{"operator"=>"equal", "value"=>["1","2"]}}
    hash2 = {"done"=>{"operator"=>"inferior", "value"=>["80"]}, "category"=>{"operator"=>"different", "value"=>["1","2"]}}
    hash3 = {"created_at"=>{"operator"=>"inferior", "value"=>"2012-11-22"}, "assigned_to"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"created_at"=>{"operator"=>"inferior", "value"=>"2012-11-22"}, "assigned_to"=>{"operator"=>"equal", "value"=>["1","4"]}}
    hash5 = {"status"=>{"operator"=>"equal", "value"=>["1", "4"]}, "done"=>{"operator"=>"inferior", "value"=>["50"]}}
    hash6 = {"status"=>{"operator"=>"equal", "value"=>["1", "4"]}, "done"=>{"operator"=>"superior", "value"=>["50"]}}
    hash7 = {"status"=>{"operator"=>"different", "value"=>["1", "4"]}, "done"=>{"operator"=>"superior", "value"=>["50"]}}
    hash8 = {"status"=>{"operator"=>"different", "value"=>["1", "4"]}, "done"=>{"operator"=>"inferior", "value"=>["50"]}}
    hash9 = {"due_date"=>{"operator"=>"today", "value"=>""}, "author"=>{"operator"=>"equal", "value"=>["1"]}}

    assert([83,98].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When done <= 80 AND category id = 1')
    assert([76,83,96,98].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When done <= 80 AND (category id = 1 OR category id = 2)')
    assert([38,40,44,45,48,49,50,51,52,53,54,55,56,86,101,104].eql?(Issue.filter(hash2).collect{|issue| issue.id}), 'When done <= 80 AND (category id <> 1 OR category id <> 2)')
    assert([101,104].eql?(Issue.filter(hash3).collect{|issue| issue.id}), 'When created_at <= 2012-11_22 AND (assigned id <> 1)')
    assert([9,10,11,12,16,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,62,76,77,83,86,88,92,96,97,98,102,103,104].eql?(Issue.filter(hash4).collect{|issue| issue.id}), 'When created_at <= 2012-11_22 AND (assigned id = 1 OR assigned to = 4)')
    assert([38,40,44,48,49,50,51,52,54,55,56,76,83,86,96,101,104].eql?(Issue.filter(hash5).collect{|issue| issue.id}), 'When status equal 1,4 AND done <= 50')
    assert([9,10,11,12,16,36,37,39,41,42,43,45,46,47,55,62,77,88,92,97,102,103].eql?(Issue.filter(hash6).collect{|issue| issue.id}), 'When status equal 1,4 AND done >= 50')
    assert([].eql?(Issue.filter(hash7).collect{|issue| issue.id}), 'When status different 1,4 AND done >= 50')
    assert([53, 98].eql?(Issue.filter(hash8).collect{|issue| issue.id}), 'When status different 1,4 AND done <= 50')
    assert([9].eql?(Issue.filter(hash9).collect{|issue| issue.id}), 'When due_date today and author id  1')
  end

  def test_three_filter
    hash = {"done"=>{"operator"=>"equal", "value"=>["100"]}, "assigned_to"=>{"operator"=>"different", "value"=>["4"]}, "tracker"=>{"operator"=>"equal", "value"=>["1"]}}
    hash1 = {"status"=>{"operator"=>"equal", "value"=>["4"]}, "version"=>{"operator"=>"equal", "value"=>["2", "4"]}, "category"=>{"operator"=>"different", "value"=>["2", "3"]}}
    assert([9,10,11,12,16,36,37,39,42,43,46,47,62,77,92,103].eql?(Issue.filter(hash).collect{|issue| issue.id}), 'When done = 100 AND assigend to <> 4 AND tracker = 1')
    assert([37,39,42,46,62,103].eql?(Issue.filter(hash1).collect{|issue| issue.id}), 'When status_id = 4 AND (version_id = 2 OR version_id = 4) AND (category_id <> 2 AND category_id <> 3 OR category_id IS NULL)')
  end
end
