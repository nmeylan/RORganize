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

  test 'it has a method to build a wiki home page' do
    wiki_page, wiki, page_success, home_page_success = WikiPage.page_creation(@project.id, {title: "NEw home page", content: "My content"}, {wiki: {home_page: "true"}})
    assert_equal @wiki, wiki
    assert page_success
    assert home_page_success
    assert_equal WikiPage.find_by_wiki_id_and_title(@wiki.id, "NEw home page"), wiki_page
    @wiki.reload
    assert_equal @wiki.home_page, wiki_page
  end

  test 'it has a method to build a wiki page' do
    creation_result = WikiPage.page_creation(@project.id, {title: "NEw home page", content: "My content"}, {wiki: {home_page: "true"}})
    wiki_page, wiki, page_success, home_page_success = WikiPage.page_creation(@project.id, {title: "NEw sub page", content: "My sub page content", parent_id: "new-home-page"}, {})
    assert_equal @wiki, wiki
    assert page_success
    assert home_page_success
    assert_equal WikiPage.find_by_wiki_id_and_title(@wiki.id, "NEw sub page"), wiki_page
    assert_equal creation_result.first, wiki_page.parent
  end

  test 'it has a method to build a wiki page that should not be saved when it has no title' do
    wiki_page, wiki, page_success, home_page_success = WikiPage.page_creation(@project.id, {content: "My sub page content"}, {})
    assert_equal @wiki, wiki
    assert_not page_success
    assert home_page_success
    assert_not wiki_page.id
  end

  test 'it has a method to build a wiki page that should not save parent when this one is invalid' do
    wiki_page, wiki, page_success, home_page_success = WikiPage.page_creation(@project.id, {title: "NEw sub page", content: "My sub page content", parent_id: "new-hhome-page"}, {})
    assert_equal @wiki, wiki
    assert page_success
    assert home_page_success
    assert_equal WikiPage.find_by_wiki_id_and_title(@wiki.id, "NEw sub page"), wiki_page
    assert_not wiki_page.parent
  end

  test 'it has many sub pages and should be nullified when it is deleted' do
    wiki_page = WikiPage.create(title: 'My title 1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page1 = WikiPage.create(title: 'My title 2', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)

    assert_equal wiki_page, wiki_page1.parent
    assert_equal [wiki_page1], wiki_page.sub_pages

    wiki_page.destroy
    wiki_page1.reload
    assert_not wiki_page1.parent_id
  end

  test 'home page belongs to project and wiki home page should be nullified when it is destroyed' do
    creation_result = WikiPage.page_creation(@project.id, {title: "NEw home page", content: "My content"}, {wiki: {home_page: "true"}})
    wiki = creation_result[1]
    wiki_page = creation_result[0]

    assert_equal wiki.home_page, wiki_page

    wiki_page.destroy
    wiki.reload
    assert_not wiki.home_page
  end
end