# Author: Nicolas Meylan
# Date: 15.01.15 17:24
# Encoding: UTF-8
# File: wiki_page_test.rb
require 'test_helper'

class WikiPageTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = Project.create(name: 'Rorganize test fdp', is_public: true)
    @wiki = Wiki.create(project_id: @project.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "caption should be equal to title" do
    wiki_page = WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    assert_equal wiki_page.title, wiki_page.caption
    assert_equal 'My title', wiki_page.caption
  end

  test 'permit attributes should contains' do
    assert_equal [:parent_id, :title, :content], WikiPage.permit_attributes
  end

  test 'it should increment position on creation for a same parent id' do
    project = Project.create(name: 'Rorganize test', is_public: true)
    wiki = Wiki.create(project_id: project.id)
    wiki_page = WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page1 = WikiPage.create(title: 'My title 1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page2 = WikiPage.create(title: 'My title 4', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page3 = WikiPage.create(title: 'My title 2', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    wiki_page4 = WikiPage.create(title: 'My title 3', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    wiki_page5 = WikiPage.create(title: 'My title 3', author_id: User.current.id, content: 'content', wiki_id: wiki.id)

    assert_equal 0, wiki_page.position
    assert_equal 1, wiki_page1.position
    assert_equal 2, wiki_page2.position
    assert_equal 0, wiki_page3.position
    assert_equal 1, wiki_page4.position
    assert_equal 0, wiki_page5.position
  end

  test 'it should decrement position on deletion for a same parent id' do
    wiki_page = WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page1 = WikiPage.create(title: 'My title 1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page2 = WikiPage.create(title: 'My title 4', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page3 = WikiPage.create(title: 'My title 2', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    wiki_page4 = WikiPage.create(title: 'My title 3', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    pages = [wiki_page, wiki_page1, wiki_page2, wiki_page3, wiki_page4]

    assert_equal 0, wiki_page.position
    assert_equal 1, wiki_page1.position
    assert_equal 2, wiki_page2.position
    assert_equal 0, wiki_page3.position
    assert_equal 1, wiki_page4.position
    assert_equal nil, wiki_page.parent
    assert_equal nil, wiki_page1.parent
    assert_equal nil, wiki_page2.parent
    assert_equal wiki_page, wiki_page3.parent
    assert_equal wiki_page, wiki_page4.parent

    pages.delete_if{|page| page.id.eql?(wiki_page3.id)}
    assert wiki_page3.destroy
    pages.each(&:reload)
    assert_equal 0, wiki_page.position
    assert_equal 1, wiki_page1.position
    assert_equal 2, wiki_page2.position
    assert_equal 0, wiki_page4.position
    assert_equal nil, wiki_page.parent
    assert_equal nil, wiki_page1.parent
    assert_equal nil, wiki_page2.parent
    assert_equal wiki_page, wiki_page4.parent


    pages.delete_if{|page| page.id.eql?(wiki_page.id)}
    assert wiki_page.destroy
    pages.each(&:reload)
    assert_equal 1, wiki_page1.position
    assert_equal 2, wiki_page2.position
    assert_equal 0, wiki_page4.position
    assert_equal nil, wiki_page1.parent
    assert_equal nil, wiki_page2.parent
    assert_equal nil, wiki_page4.parent
  end

  test 'it retrieve the wiki project id' do
    wiki_page = WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    assert_equal @wiki.project_id, wiki_page.project_id
    assert_equal @project.id, wiki_page.project_id
  end

  test 'it has a method to build wiki pages' do

  end
end