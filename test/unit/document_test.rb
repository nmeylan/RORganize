# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issue_test.rb
# require 'test/unit'
require 'test_helper'
class DocumentTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end

  test "Filtered attributes" do
    expectation = [["Name", "name"], ["Version", "version"], ["Category", "category"], ["Created at", "created_at"], ["Updated at", "updated_at"]]
    actual = Document.filtered_attributes
    assert_equal expectation, actual
  end
  test "attributes_formalized_names" do
    expectation = ["Name", "Description", "Version", "Category", "Project", "Created at", "Updated at"]
    actual = Document.attributes_formalized_names
    p actual
    assert_equal expectation, actual
  end


end