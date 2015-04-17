# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment_test.rb
require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @issue = Issue.create(subject: 'test', description: 'sample issue', tracker_id: Tracker.first.id, author_id: User.current.id, status_id: IssuesStatus.first.id, project: projects(:projects_666))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @issue.destroy
  end

  def create_comment
    comment = Comment.new(content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: @issue.sequence_id, commentable_type: 'Issue')

    assert_nil comment.id
    @issue.comments << comment
    assert @issue.save
    assert_not_nil comment.id
    assert_equal [comment], @issue.comments
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
    comment.project_id = 1
    assert_equal true, @issue.save
  end

  test 'it know if it has been commented' do
    comment = create_comment
    comment.content = 'Edit'
    assert_equal false, comment.edited?
    comment.created_at = Time.now - 1
    assert_equal true, comment.save
    assert_equal true, comment.edited?
  end

  test 'it is in a discussion thread' do
    comment1 = Comment.new({content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: 1, commentable_type: 'Issue'})
    comment2 = Comment.new({content: 'this a second comment in same thread', user_id: User.current.id, project_id: 1, commentable_id: 1, commentable_type: 'Issue'})
    comment3 = Comment.new({content: 'this a third comment in another thread', user_id: User.current.id, project_id: 1, commentable_id: 2, commentable_type: 'Issue'})

    comment1.save
    comment2.save
    comment3.save
    assert_equal 2, comment1.thread_comment_count
    assert_equal 2, comment2.thread_comment_count
    assert_equal 1, comment3.thread_comment_count
  end

  test 'it know if the given user is the author or not' do
    comment1 = Comment.new({content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: 1, commentable_type: 'Issue'})
    assert comment1.author?(User.current), 'Current user is the author'
    refute comment1.author?(users(:users_002)), 'User 002 is not the author'
  end

  test 'permit attributes should contains' do
    assert_equal [:commentable_id, :commentable_type, :content, :parent_id, :project_id], Comment.permit_attributes
  end

  test 'it has a polymorphic identifier to retrieve the belonging object' do
    comment1 = Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                               commentable_id: 1, commentable_type: 'Issue'})
    assert_equal :Issue_1, comment1.polymorphic_identifier
  end

  test 'class build a date range for history display' do
    date = Date.new(2001, 2, 3)
    assert_equal (Date.new(2001, 1, 28))..(Date.new(2001, 2, 4)), Comment.build_date_range(date, :ONE_WEEK)
    assert_equal (Date.new(2001, 2, 1))..(Date.new(2001, 2, 4)), Comment.build_date_range(date, :THREE_DAYS)
    assert_equal (Date.new(2001, 2, 3))..(Date.new(2001, 2, 4)), Comment.build_date_range(date, :ONE_DAY)
    assert_equal (Date.new(2001, 1, 4))..(Date.new(2001, 2, 4)), Comment.build_date_range(date, :ONE_MONTH)
  end

  test 'scope that eager load all comments for issue type for a given time range.' do
    date1 = Time.new(2001, 2, 2, 13, 30, 0)
    date2 = Time.new(2001, 2, 1, 14, 30, 0)
    date3 = Time.new(2001, 2, 3, 14, 30, 0)
    date1_out_of_range = Time.new(2001, 2, 4, 14, 30, 0)
    date2_out_of_range = Time.new(2001, 1, 31, 14, 30, 0)
    dates = []
    dates << date1 << date2 << date3 << date1_out_of_range << date2_out_of_range
    comments = dates.collect do |date|
      Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: 1, commentable_type: 'Issue', created_at: date})
    end

    expected_result = comments[0, 3]

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array expected_result, Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 1').to_a

    range_end_date = Date.new(2001, 2, 4)
    period = :ONE_WEEK
    assert_match_array comments, Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 1').to_a
  end

  test 'scope that eager load all comments for given object type for a given time range.' do
    date1 = Time.new(2001, 2, 2, 13, 30, 0)
    date2 = Time.new(2001, 2, 1, 14, 30, 0)
    date3 = Time.new(2001, 2, 3, 14, 30, 0)
    date4 = Time.new(2001, 2, 4, 14, 30, 0)
    date5 = Time.new(2001, 1, 31, 14, 30, 0)
    dates = []
    dates << date1 << date2 << date3 << date4 << date5
    issues_comments = []
    documents_comments = []
    issues_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date1})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date2})

    issues_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                       commentable_id: 1, commentable_type: 'Issue', created_at: date3})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date4})

    documents_comments << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                          commentable_id: 1, commentable_type: 'Document', created_at: date5})

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array issues_comments,
                       Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 1').to_a

    assert_match_array documents_comments[0, 1],
                       Comment.comments_eager_load(['Document'], period, range_end_date, 'comments.project_id = 1').to_a

    assert_match_array issues_comments + documents_comments[0, 1],
                       Comment.comments_eager_load(['Issue', 'Document'], period, range_end_date, 'comments.project_id = 1').to_a

    range_end_date = Date.new(2001, 2, 4)
    period = :ONE_WEEK
    assert_match_array issues_comments,
                       Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 1').to_a

    assert_match_array documents_comments,
                       Comment.comments_eager_load(['Document'], period, range_end_date, 'comments.project_id = 1').to_a

    assert_match_array issues_comments + documents_comments,
                       Comment.comments_eager_load(['Issue', 'Document'], period, range_end_date, 'comments.project_id = 1').to_a


  end

  test 'scope that eager load all comments for given object type for a given time range with condition.' do
    date1 = Time.new(2001, 2, 2, 13, 30, 0)
    date2 = Time.new(2001, 2, 1, 14, 30, 0)
    date3 = Time.new(2001, 2, 3, 14, 30, 0)
    dates = []
    dates << date1 << date2 << date3
    issues_comments_project2 = []
    issues_comments_project1 = []
    issues_comments_project1 << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                                commentable_id: 1, commentable_type: 'Issue', created_at: date1})

    issues_comments_project1 << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                                                commentable_id: 1, commentable_type: 'Issue', created_at: date2})

    issues_comments_project2 << Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 2,
                                                commentable_id: 1, commentable_type: 'Issue', created_at: date3})

    range_end_date = Date.new(2001, 2, 3)
    period = :THREE_DAYS
    assert_match_array issues_comments_project1,
                       Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 1').to_a
    assert_match_array issues_comments_project2,
                       Comment.comments_eager_load(['Issue'], period, range_end_date, 'comments.project_id = 2').to_a
  end

  test 'it increment or decrement issue comment counter cache' do
    issue = Issue.create(tracker_id: 1, subject: 'Bug', status_id: 1, author_id: User.current.id, project: projects(:projects_666))

    assert_equal issue.comments_count, 0
    comment = Comment.create({content: 'this a comment', user_id: User.current.id, project_id: 1,
                    commentable_id: issue.id, commentable_type: 'Issue'})
    issue.reload
    assert_equal issue.comments_count, 1

    comment.destroy
    issue.reload
    assert_equal issue.comments_count, 0
  end
end