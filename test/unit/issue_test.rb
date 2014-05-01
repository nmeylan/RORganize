class IssueTest < ActiveSupport::TestCase
  require 'test_helper'
  include IssuesHelper
  include Rorganize::MagicFilter

  def test_subject_filter
    hash = {"subject"=>{"operator"=>"contains", "value"=>"me"}}
    hash1 = {"subject"=>{"operator"=>"contains", "value"=>"Issue"}}
    hash2 = {"subject"=>{"operator"=>"not contains", "value"=>"p"}}
    a = Issue.count
    assert_equal([45,62,97,102,141,225,226,234,238,251,262,267,271], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'contains me')
    assert_equal([9,16,36,37,42,62,77,88,105,224,226,233,237,242], Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}, 'When subject contains Issue')
    assert_equal([10,12,16,36,39,42,45,46,49,51,53,76,86,96,106,120,129,130,132,133,135,137,138,139,141,225,226,232,234,236,242,251,253,254,258,259,260,262,264,265,266,267,271], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}), 'When subject not contains any p')
  end

  def test_author_filter
    hash = {"author"=>{"operator"=>"equal", "value"=>["4"]}}
    hash1 = {"author"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"author"=>{"operator"=>"different", "value"=>["4"]}}
    hash3 = {"author"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"author"=>{"operator"=>"different", "value"=>["1", "4"]}}
    hash5 = {"author"=>{"operator"=>"equal", "value"=>["1", "4"]}}
    assert_equal([102], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When author id is 4')
    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,239,242,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,275], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When author id is 1')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,239,242,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], ((Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}).sort), 'When author id <> 4')

    assert_equal([102,269,271], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}), 'When author id <> 1')

    assert_equal([269, 271], (Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}), 'When author id <> 1,4')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,239,242,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,275], (Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}), 'When author id = 1 or 4')
  end

  def test_assigned_filter
    hash = {"assigned_to"=>{"operator"=>"equal", "value"=>["4"]}}
    hash1 = {"assigned_to"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"assigned_to"=>{"operator"=>"different", "value"=>["4"]}}
    hash3 = {"assigned_to"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"assigned_to"=>{"operator"=>"different", "value"=>["1", "4"]}}
    hash5 = {"assigned_to"=>{"operator"=>"equal", "value"=>["1", "4"]}}
    assert_equal([102], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When assigned_to id is 4')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,140,141,218,220,221,224,225,226,227,231,232,233,234,235,236,237,239,242,243,244,245,246,251,259,264,265,266,267,275], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When assigned to = 1')

    assert_equal([9, 10, 11, 12, 16, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 62, 76, 77, 86, 88, 92, 96, 97, 98, 105, 106, 120, 121, 122, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 218, 220, 221, 224, 225, 226, 227, 231, 232, 233, 234, 235, 236, 237, 238, 239, 242, 243, 244, 245, 246, 251, 252, 253, 254, 258, 259, 260, 262, 264, 265, 266, 267, 269, 271, 275], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}).sort, 'When assigned_to id <> 4')

    assert_equal([102, 139, 142, 238, 252, 253, 254, 258, 260, 262, 269, 271], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}).sort, 'When assigned_to id <> 1')

    assert_equal([139, 142, 238, 252, 253, 254, 258, 260, 262, 269, 271], (Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}).sort, 'When assigned_to id <> 1,4')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,140,141,218,220,221,224,225,226,227,231,232,233,234,235,236,237,239,242,243,244,245,246,251,259,264,265,266,267,275],(Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}), 'When assigned_to id = 1,4')
  end

  def test_tracker_filter
    hash = {"tracker"=>{"operator"=>"equal", "value"=>["1", "2"]}}
    hash1 = {"tracker"=>{"operator"=>"equal", "value"=>["1"]}}
    hash2 = {"tracker"=>{"operator"=>"equal", "value"=>["2"]}}
    hash3 = {"tracker"=>{"operator"=>"different", "value"=>["1","2"]}}
    hash4 = {"tracker"=>{"operator"=>"different", "value"=>["1"]}}
    hash5 = {"tracker"=>{"operator"=>"different", "value"=>["2"]}}

    assert_equal([9, 10, 11, 12, 16, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 62, 76, 77, 86, 88, 92, 96, 97, 98, 102, 105, 106, 120, 121, 122, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 218, 220, 221, 224, 225, 226, 227, 231, 232, 233, 234, 235, 236, 237, 238, 239, 242, 243, 244, 245, 246, 251, 252, 253, 254, 258, 259, 260, 262, 264, 265, 266, 267, 269, 271, 275],(Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is 1 OR 2')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,92,96,98,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,225,226,227,233,234,236,238,239,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is 1')

    assert_equal([88,97,102,224,231,232,235,237,242], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is 2')

    assert_equal([], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is different 1 AND 2')

    assert_equal([88,97,102,224,231,232,235,237,242,],(Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is different 1')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,92,96,98,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,225,226,227,233,234,236,238,239,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275],(Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}), 'When tracker is different 2')
  end

  def test_status_filter
    hash = {"status"=>{"operator"=>"equal", "value"=>["1", "2", "3"]}}
    hash1 = {"status"=>{"operator"=>"different", "value"=>["1", "2", "3"]}}
    hash2 = {"status"=>{"operator"=>"equal", "value"=>["1"]}}
    hash3 = {"status"=>{"operator"=>"different", "value"=>["1"]}}
    hash4 = {"status"=>{"operator"=>"different", "value"=>["1", "6", "7"]}}
    hash5 = {"status"=>{"operator"=>"equal", "value"=>["4"]}}
    hash6 = {"status"=>{"operator"=>"different", "value"=>["4"]}}

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,120,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,227,231,232,233,234,235,236,237,238,242,243,244,245,252,253,254,258,260,262,269,271,275], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When status is 1 OR 2 OR 3')

    assert_equal([106,121,226,239,246,251,259,264,265,266,267], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1 AND 2 AND 3')

    assert_equal([48,49,50,51,54,105,122,218,220,238,245,269,275], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}), 'When status is 1')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,53,55,56,62,76,77,86,88,92,96,97,98,102,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,221,224,225,226,227,231,232,233,234,235,236,237,239,242,243,244,246,251,252,253,254,258,259,260,262,264,265,266,267,271], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,53,55,56,62,76,77,86,88,92,96,97,98,102,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,221,224,225,226,227,231,232,233,234,235,236,237,239,242,243,244,246,251,252,253,254,258,259,260,262,264,265,266,267,271], (Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1 AND 6 AND 7')

    assert_equal([106,121,226,239,246,251,259,264,265,266,267], (Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}), 'When status is 4')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,120,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,227,231,232,233,234,235,236,237,238,242,243,244,245,252,253,254,258,260,262,269,271,275], (Issue.where(issues_filter(hash6)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 4')
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

    assert_equal([9,10,11,12,16,36,37,39,41,42,43,46,47,54,55,56,92,96,122,239,246], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When status is 1 OR 2')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,53,54,55,56,62,76,86,92,96,98,122,218,221,225,226,239,246], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When status is 1 OR 2 OR 4')

    assert_equal([48,49,50,51,77,88,97,102,105,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,220,224,227,231,232,233,234,235,236,237,238,242,243,244,245,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1 AND  2 AND 4')

    assert_equal([38,44,45,48,49,50,51,53,62,76,77,86,88,97,98,102,105,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,242,243,244,245,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1 AND  2')

    assert_equal([9,10,11,12,16,36,37,39,41,42,246], (Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}), 'When status is 1')

    assert_equal([38,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,106,120,121,122,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,239,242,243,244,245,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], (Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 1')

    assert_equal([43,46,47,54,55,56,92,96,122,239], (Issue.where(issues_filter(hash6)+" 1 = 1").collect{|issue| issue.id}), 'When status is 2')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,44,45,48,49,50,51,53,62,76,77,86,88,97,98,102,105,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,218,220,221,224,225,226,227,231,232,233,234,235,236,237,238,242,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,269,271,275], (Issue.where(issues_filter(hash7)+" 1 = 1").collect{|issue| issue.id}), 'When status is not 2')
  end

  def test_created_at_filter
    hash = {"created_at"=>{"operator"=>"equal", "value"=>"2012-08-03"}}
    hash1 = {"created_at"=>{"operator"=>"superior", "value"=>"2013-04-22"}}
    hash2 = {"created_at"=>{"operator"=>"inferior", "value"=>"2012-09-08"}}
    hash3 = {"created_at"=>{"operator"=>"equal", "value"=>"2012-11-10"}}
    hash4 = {"created_at"=>{"operator"=>"equal", "value"=>"2012-10-23"}}

    assert_equal([9,10,11,12,16], Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}, 'When created = 2012-08-03')

    assert_equal([269,271,275], (Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}), 'When created >= 2013-04-22')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56], (Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}), 'When created <= 2012-09-08 ')

    assert_equal([105], (Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}), 'When created = 2012-11-10')

    assert_equal([96,97,98, 102], (Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}), 'When created = 2012-10-23')
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

    assert_equal([98], (Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}), 'When done <= 80 AND category id = 1')

    assert_equal([44,45,48,49,50,51,54,76, 98, 105,122,218,220], Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}, 'When done <= 80 AND (category id = 1 OR category id = 2)')

    assert_equal([238, 269, 275], Issue.where(issues_filter(hash2)+" 1 = 1").collect{|issue| issue.id}, 'When done <= 80 AND (category id <> 1 AND category id <> 2)')

    assert_equal([102], Issue.where(issues_filter(hash3)+" 1 = 1").collect{|issue| issue.id}, 'When created_at <= 2012-11-22 AND (assigned id <> 1)')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,53,54,55,56,62,76,77,86,88,92,96,97,98,102,105,106,120,121], Issue.where(issues_filter(hash4)+" 1 = 1").collect{|issue| issue.id}, 'When created_at <= 2012-11-22 AND (assigned id = 1 OR assigned to = 4)')

    assert_equal([48,49,50,51,54,105,122,218,220,238,269,275], Issue.where(issues_filter(hash5)+" 1 = 1").collect{|issue| issue.id}, 'When status equal 1,4 AND done <= 50')

    assert_equal([106,121,226,239,245,246,251,259,264,265,266,267], Issue.where(issues_filter(hash6)+" 1 = 1").collect{|issue| issue.id}, 'When status equal 1,4 AND done >= 50')

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,44,45,46,47,53,55,56,62,76,77,86,88,92,96,97,98,102,120,129,130,131,132,133,134,135,136,137,138,139,140,141,142,221,224,225,227,231,232,233,234,235,236,237,242,243,244,252,253,254,258,260,262,271], Issue.where(issues_filter(hash7)+" 1 = 1").collect{|issue| issue.id}, 'When status different 1,4 AND done >= 50')
    assert_equal([], Issue.where(issues_filter(hash8)+" 1 = 1").collect{|issue| issue.id}, 'When status different 1,4 AND done <= 50')
  end

  def test_three_filter
    hash = {"done"=>{"operator"=>"equal", "value"=>["100"]}, "assigned_to"=>{"operator"=>"different", "value"=>["4"]}, "tracker"=>{"operator"=>"equal", "value"=>["1"]}}
    hash1 = {"status"=>{"operator"=>"equal", "value"=>["4"]}, "version"=>{"operator"=>"equal", "value"=>["2", "4"]}, "category"=>{"operator"=>"different", "value"=>["2", "3"]}}

    assert_equal([9,10,11,12,16,36,37,38,39,41,42,43,46,47,53,55,56,62,77,86,92,96,106,120,121,129,130,131,132,133,134,135,136,137,138,139,140,141,142,221,225,226,227,233,234,236,239,243,244,245,246,251,252,253,254,258,259,260,262,264,265,266,267,271], Issue.where(issues_filter(hash)+" 1 = 1").collect{|issue| issue.id}, 'When done = 100 AND assigend to <> 4 AND tracker = 1')

    assert_equal([], Issue.where(issues_filter(hash1)+" 1 = 1").collect{|issue| issue.id}, 'When status_id = 4 AND (version_id = 2 OR version_id = 4) AND (category_id <> 2 AND category_id <> 3 OR category_id IS NULL)')
  end
end
