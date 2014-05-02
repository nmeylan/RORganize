# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issue_status_test.rb

class IssueStatusTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @status = IssuesStatus.new({default_done_ratio: 0, is_closed: 0})
    @enumeration = Enumeration.new(name: 'TEST_STATUS', opt: 'ISTS')
    @status.enumeration = @enumeration
    @status.save
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @status.destroy
  end

  test "Increment position on enumeration create" do
    statuses = Enumeration.where(opt: 'ISTS').order("position ASC")
    i = 1
    #Check uniq position
    statuses.each do |status|
      assert_equal status.position, i
      i += 1
    end
    #Check last enumeration created equal last index
    assert_equal @enumeration.position, i - 1
  end

  test "Decrement position" do
    old_position = @status.enumeration.position
    @status.change_position('dec')
    @status.change_position('dec')
    @status.reload
    assert_equal old_position - 2, @status.enumeration.position
  end

  test "Increment position must fail" do
    old_position = @status.enumeration.position
    @status.change_position('inc')
    @status.reload
    assert_equal old_position, @status.enumeration.position
  end

  test "Crap param position must fail" do
    old_position = @status.enumeration.position
    @status.change_position('crap')
    @status.reload
    assert_equal old_position, @status.enumeration.position
  end
end