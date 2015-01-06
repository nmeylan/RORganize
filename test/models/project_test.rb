# Author: Nicolas Meylan
# Date: 24.06.14
# Encoding: UTF-8
# File: project_test.rb
require 'test_helper'
class ProjectTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.current = User.find_by_id(1)
    @project = Project.where(id: 1).first

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @project.destroy
  end


  test 'Road map data structure' do
    expected_array_size = 7 #6 versions + unplanned
    expected_structure = {1 => {percent: 100, opened_issues_count: 1, closed_issues_count: 10, issues: 11},
                          2 => {percent: 80, opened_issues_count: 3, closed_issues_count: 7, issues: 10},
                          4 => {percent: 84, opened_issues_count: 5, closed_issues_count: 7, issues: 12},
                          7 => {percent: 100, opened_issues_count: 0, closed_issues_count: 4, issues: 4},
                          8 => {percent: 100, opened_issues_count: 1, closed_issues_count: 13, issues: 14},
                          12 => {percent: 100, opened_issues_count: 2, closed_issues_count: 1, issues: 3},
                          nil => {percent: 0, opened_issues_count: 7, closed_issues_count: 0, issues: 7}}
    structure = @project.roadmap
    assert_equal expected_array_size, structure.keys.size
    expected_structure.each do |key, value|
      assert_equal value[:percent], structure[key][:percent].floor
      assert_equal value[:opened_issues_count], structure[key][:opened_issues_count]
      assert_equal value[:closed_issues_count], structure[key][:closed_issues_count]
      assert_equal value[:issues], structure[key][:issues].size
    end
  end


end