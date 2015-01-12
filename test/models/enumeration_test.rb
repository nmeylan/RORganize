# Author: Nicolas Meylan
# Date: 09.01.15
# Encoding: UTF-8
# File: enumeration_test.rb
require 'test_helper'

class EnumerationTest < ActiveSupport::TestCase

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

  test 'caption should be equal to name' do
    name = 'Hello'
    enumeration = Enumeration.new(name: name)
    assert_equal name, enumeration.caption
    assert_equal name, enumeration.name
  end

  test 'permit attributes should contains' do
    assert_equal [:opt, :name, :position], Enumeration.permit_attributes
  end

  test 'it should not save an enumeration without a valid name' do
    enumeration = Enumeration.new(name: '', opt: 'test')
    assert_not enumeration.save, 'Saved with an empty name'

    enumeration.name = 'a'
    assert_not enumeration.save, 'Saved with a single char name'

    enumeration.name = generate_string_of_length(256) # > 20 char, 20 char max is the constraints
    assert_not enumeration.save, 'Saved with more than 20 char name'

    enumeration.name = 'qwertz'
    assert enumeration.save, enumeration.errors.messages
  end

  test 'it should not save an enumeration without a valid opt' do
    enumeration = Enumeration.new(name: 'enum')
    assert_not enumeration.save, 'Saved with an empty opt'

    enumeration.opt = 'a'
    assert_not enumeration.save, 'Saved with a single char opt'

    enumeration.opt = 'abcde' # > 20 char, 20 char max is the constraints
    assert_not enumeration.save, 'Saved with more than 4 char name'

    enumeration.opt = 'test'
    assert enumeration.save, enumeration.errors.messages
  end

  test 'name should be uniq with the same opt' do
    enumeration = Enumeration.new(name: 'enum', opt: 'test')
    assert enumeration.save, enumeration.errors.messages

    enumeration = Enumeration.new(name: 'enum', opt: 'test')
    assert_not enumeration.save
  end

  test 'before create trigger increment position on creation' do
    enumeration1 = Enumeration.create(name: 'Enum1', opt: 'test')
    assert_equal 1, enumeration1.position
    enumeration2 = Enumeration.create(name: 'Enum2', opt: 'test')
    assert_equal 2, enumeration2.position
    enumeration3 = Enumeration.create(name: 'Enum3', opt: 'test')
    assert_equal 3, enumeration3.position
  end

  test 'before create trigger decrement position on deletion' do
    enumeration1 = Enumeration.create(name: 'Enum1', opt: 'test')
    enumeration2 = Enumeration.create(name: 'Enum2', opt: 'test')
    enumeration3 = Enumeration.create(name: 'Enum3', opt: 'test')

    enumeration2.destroy
    enumeration3.reload
    assert_equal 2, enumeration3.position


    enumeration2 = Enumeration.create(name: 'Enum2', opt: 'test')
    assert_equal 3, enumeration2.position
    assert_equal 1, enumeration1.position
    assert_equal 2, enumeration3.position

    enumeration1.destroy
    enumeration3.reload
    enumeration3.destroy
    enumeration2.reload
    assert_equal 1, enumeration2.position
  end
end