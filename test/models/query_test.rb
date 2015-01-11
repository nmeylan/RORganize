# Author: Nicolas Meylan
# Date: 11.01.15
# Encoding: UTF-8
# File: query_test.rb
require 'test_helper'

class QueryTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = Project.create(name: 'Rorganize test', is_public: true)
    @attributes = {"name" => "Parker Ferry opened", "description" => "", "is_public" => "0", "is_for_all" => "0", "object_type" => "Issue"}
    @filters = {"status" => {"operator" => "equal", "value" => ["1", "2", "4"]}, "assigned_to" => {"operator" => "equal", "value" => ["7"]}}
    @user2 = users(:users_002)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  test 'permit attributes should contains' do
    assert_equal [:is_for_all, :is_public, :name, :description, :object_type, :id], Query.permit_attributes
  end

  test 'caption should be equal to name' do
    query = queries(:queries_001)
    assert_equal query.name, query.caption
  end

  test 'has a method to create query' do
    query = Query.create_query(@attributes, @project, @filters)
    assert query.save
    expected_condition = '(issues.status_id <=> \'1\' OR issues.status_id <=> \'2\' OR issues.status_id <=> \'4\' ) AND '
    expected_condition += '(issues.assigned_to_id <=> \'7\' ) AND'
    assert_equal expected_condition, query.stringify_query
    assert_equal @filters.inspect, query.stringify_params
  end

  test 'scope available for' do
    query = Query.create_query(@attributes, @project, @filters)
    project2 = Project.create(name: 'Rorganize test bis', is_public: true)

    assert query.save
    assert_equal [query], Query.available_for(User.current, @project.id, 'Issue').to_a
    assert_equal [], Query.available_for(User.current, project2.id, 'Issue').to_a
    assert_equal [], Query.available_for(@user2, @project.id, 'Issue').to_a
    assert_equal [], Query.available_for(@user2, project2.id, 'Issue').to_a


    attributes = {"name" => "Parker Ferry opened for all projects", "description" => "",
                  "is_public" => "0", "is_for_all" => "1", "object_type" => "Issue"}
    query2 = Query.create_query(attributes, project2, @filters)
    assert query2.save
    assert_equal [query, query2], Query.available_for(User.current, @project.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(User.current, project2.id, 'Issue').to_a
    assert_equal [], Query.available_for(@user2, @project.id, 'Issue').to_a
    assert_equal [], Query.available_for(@user2, project2.id, 'Issue').to_a

    query2.is_public = true
    assert query2.save
    assert_equal [query, query2], Query.available_for(User.current, @project.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(User.current, project2.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(@user2, @project.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(@user2, project2.id, 'Issue').to_a

    query2.is_for_all = false
    assert query2.save
    assert_equal [query], Query.available_for(User.current, @project.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(User.current, project2.id, 'Issue').to_a
    assert_equal [], Query.available_for(@user2, @project.id, 'Issue').to_a
    assert_equal [query2], Query.available_for(@user2, project2.id, 'Issue').to_a
  end

  test 'scope public queries' do
    query = Query.create_query(@attributes, @project, @filters)

    assert query.save
    assert_equal [], Query.public_queries(@project.id).to_a

    query.is_public = true
    assert query.save
    assert_equal [query], Query.public_queries(@project.id).to_a

    query.is_for_all = true
    assert query.save
    assert_equal [], Query.public_queries(@project.id)

    attributes = {"name" => "Parker Ferry opened user 2", "description" => "",
                  "is_public" => "0", "is_for_all" => "0", "object_type" => "Issue"}
    query2 = Query.create_query(attributes, @project, @filters)
    assert query2.save
    assert_equal [], Query.public_queries(@project.id).to_a

    query2.is_public = true
    assert query2.save
    assert_equal [query2], Query.public_queries(@project.id).to_a

    query.is_public = true
    query.is_for_all = false
    assert query.save
    assert_equal [query, query2], Query.public_queries(@project.id).to_a
  end

  test 'scope created by and private' do
    project2 = Project.create(name: 'Rorganize test bis', is_public: true)

    query = Query.create_query(@attributes, @project, @filters)
    assert query.save
    assert_equal [query], Query.created_by(User.current).to_a

    attributes = {"name" => "Parker Ferry opened user 2", "description" => "",
                  "is_public" => "0", "is_for_all" => "0", "object_type" => "Issue"}
    query2 = Query.create_query(attributes, project2, @filters)
    assert query2.save
    assert_equal [query, query2], Query.created_by(User.current).to_a
  end

  test 'it should not be saved if attributes are missings' do
    attributes = {"description" => "",
                  "is_public" => "0", "is_for_all" => "0", "object_type" => "Issue"}
    query = Query.create_query(attributes, @project, @filters)
    assert_not query.save

    attributes = {"name" => "Parker Ferry opened user 2", "description" => "",
                  "is_public" => "0", "is_for_all" => "0"}
    query = Query.create_query(attributes, @project, @filters)
    assert_not query.save

    query = Query.create_query(@attributes, @project, {})
    assert_not query.save

    query = Query.create_query(@attributes, @project, @filters)
    assert query.save
  end
end