# Author: Nicolas Meylan
# Date: 06.01.15
# Encoding: UTF-8
# File: category_test.rb
require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

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

  test "it should not save a category without a valid name" do
    category = Category.new({name: ''})
    assert_not category.save, 'Saved with an empty name'

    category.name = 'a'
    assert_not category.save, 'Saved with a single char name'

    category.name = 'qwertz'
    assert category.save
  end
end