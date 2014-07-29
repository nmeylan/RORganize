# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment_test.rb
require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.current = User.find_by_id(1)
    @issue = Issue.new({subject: 'test', description: 'sample issue', tracker_id: Tracker.first.id, author_id: User.current.id, status_id: IssuesStatus.first.id})
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @issue.destroy
  end

  def create_comment
    comment = Comment.new({content: 'this a comment', user_id: User.current.id})
    @issue.comments << comment
    assert_nil comment.id
    assert_equal true, @issue.save
    assert_not_nil comment.id
    @issue.comments.first
  end

  test 'comment creation' do
    create_comment
  end

  test 'find comment author' do
    comment = create_comment
    assert_not_nil comment.author
    assert_equal User.current.caption, comment.author.caption
  end

  test 'validation error : comment presence' do
    comment = Comment.new({user_id: User.current.id})
    @issue.comments << comment
    assert_equal false, @issue.save
    comment.content = ' '
    assert_equal false, @issue.save
    comment.content = 'This is a comment'
    assert_equal true, @issue.save
  end

  test 'edited?' do
    comment = create_comment
    comment.content = 'Edit'
    assert_equal false, comment.edited?
    comment.created_at = Time.now - 1
    assert_equal true, comment.save
    assert_equal true, comment.edited?
  end

end