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

    category.name = 'abcdefghklmnopqrstuvwxyz' # > 20 char, 20 char max is the constraints
    assert_not category.save, 'Saved with more than 20 char name'

    category.name = 'qwertz'
    assert category.save, category.errors.messages
  end

  test 'caption should be equal to name' do
    name = 'Hello'
    category = Category.new(name: name)
    assert_equal name, category.caption
    assert_equal name, category.name
  end

  test 'permit attributes should contains' do
    assert_equal [:name], Category.permit_attributes
  end

  test 'it has many issues and nullify when category is deleted' do
    category = Category.create(name: 'Hello')
    issue = Issue.create(tracker_id: 1, category_id: category.id, subject: 'Bug', status_id: 1, author_id: User.current.id)

    assert_equal category.id, issue.category_id

    category.destroy
    issue.reload # By pass cache
    assert_nil issue.category_id
  end

  test 'it belongs to one project' do
    project = Project.new(name: 'RORganize-test')
    assert project.save, project.errors.messages

    category = Category.new(name: 'Hello')
    category.project = project
    assert category.save, category.errors.messages

    project.reload
    category.reload
    assert_equal project.id, category.project_id
  end


end