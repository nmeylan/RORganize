# Author: Nicolas Meylan
# Date: 16.01.15 15:55
# Encoding: UTF-8
# File: issue_commentable_test.rb
require 'test_helper'

class IssueCommentableTest < ActiveSupport::TestCase

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

  test "issue has many comments and should be destroy when commentable is destroyed" do
    issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: 1, due_date: '2012-12-31')
    comment = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')
    comment1 = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')
    comment2 = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')

    assert_equal [comment, comment1, comment2], issue.comments.to_a

    issue.destroy
    assert_raise(ActiveRecord::RecordNotFound) {comment.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment1.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment2.reload}
  end

  test "does issue has been commented" do
    issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: 1, due_date: '2012-12-31')
    assert_not issue.commented?

    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')
    assert comment.save

    issue.reload
    assert issue.commented?
  end

  test "issue has a method to bulk delete all comments for a given commentable items" do
    issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: 1, due_date: '2012-12-31')
    comment = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')
    comment1 = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: issue.id, commentable_type: 'Issue')
    comment2 = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: 666, commentable_type: 'Issue')
    assert comment.save
    assert comment1.save
    assert comment2.save

    Commentable::bulk_delete_dependent([issue.id], 'Issue')
    assert issue.reload
    assert_raise(ActiveRecord::RecordNotFound) {comment.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment1.reload}
    assert comment2.reload
  end
end