# Author: Nicolas Meylan
# Date: 16.01.15 15:55
# Encoding: UTF-8
# File: issue_commentable_test.rb
require 'test_helper'

class DocumentCommentableTest < ActiveSupport::TestCase

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

  test "document has many comments and should be destroy when commentable is destroyed" do
    document = Document.create(name: 'Issue creation', description: '', project_id: 1)
    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    comment1 = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    comment2 = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    assert comment.save
    assert comment1.save
    assert comment2.save
    assert_equal [comment, comment1, comment2], document.comments

    document.destroy
    assert_raise(ActiveRecord::RecordNotFound) {comment.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment1.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment2.reload}
  end

  test "does document has been commented" do
    document = Document.create(name: 'Issue creation', description: '', project_id: 1)
    assert_not document.commented?

    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    assert comment.save

    document.reload
    assert document.commented?
  end

  test "document has a method to bulk delete all comments for a given commentable items" do
    document = Document.create(name: 'Issue creation', description: '', project_id: 1)
    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    comment1 = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: document.id, commentable_type: 'Document')
    comment2 = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: 666, commentable_type: 'Document')
    assert comment.save
    assert comment1.save
    assert comment2.save

    Rorganize::Models::Commentable::bulk_delete_dependent([document.id], 'Document')
    assert document.reload
    assert_raise(ActiveRecord::RecordNotFound) {comment.reload}
    assert_raise(ActiveRecord::RecordNotFound) {comment1.reload}
    assert comment2.reload
  end
end