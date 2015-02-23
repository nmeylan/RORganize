# Author: Nicolas Meylan
# Date: 15.01.15 16:17
# Encoding: UTF-8
# File: wiki_test.rb
require 'test_helper'

class WikiTest < ActiveSupport::TestCase

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

  test "caption should be equal to wiki" do
    assert_equal 'Wiki', @wiki.caption
  end

  test 'it should not be saved if project is is missing or if it is not uniq' do
    wiki = Wiki.new
    assert_not wiki.save

    wiki.project_id = @project.id
    assert_not wiki.save

    wiki.project_id = 666
    assert wiki.save, wiki.errors.messages
  end

  test 'it has a method to organize pages' do
    wiki_page = WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)
    wiki_page1 = WikiPage.create(title: 'My title 1', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    wiki_page2 = WikiPage.create(title: 'My title 2', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page.id)
    wiki_page3 = WikiPage.create(title: 'My title 3', author_id: User.current.id, content: 'content', wiki_id: @wiki.id, parent_id: wiki_page1.id)
    wiki_page4 = WikiPage.create(title: 'My title 4', author_id: User.current.id, content: 'content', wiki_id: @wiki.id)

    @wiki.pages << wiki_page
    @wiki.pages << wiki_page1
    @wiki.pages << wiki_page2
    @wiki.pages << wiki_page3
    @wiki.pages << wiki_page4
    assert @wiki.save, @wiki.errors.messages
    assert_equal 5, @wiki.pages.count

    assert_equal nil, wiki_page.parent
    assert_equal wiki_page, wiki_page1.parent
    assert_equal wiki_page, wiki_page2.parent
    assert_equal wiki_page1, wiki_page3.parent
    assert_equal nil, wiki_page4.parent
    assert_equal 0, wiki_page.position
    assert_equal 0, wiki_page1.position
    assert_equal 1, wiki_page2.position
    assert_equal 0, wiki_page3.position
    assert_equal 1, wiki_page4.position

    new_organization = {wiki_page1.id.to_s => {'parent_id' => nil, 'position' => 0},
                        wiki_page3.id.to_s => {'parent_id' => wiki_page2.id, 'position' => 0},
                        wiki_page4.id.to_s => {'parent_id' => nil, 'position' => 1},
                        wiki_page.id.to_s => {'parent_id' => nil, 'position' => 2}
    }
    Wiki.organize_pages(new_organization)

    @wiki.pages.each(&:reload)

    assert_equal nil, wiki_page.parent
    assert_equal nil, wiki_page1.parent
    assert_equal wiki_page, wiki_page2.parent
    assert_equal wiki_page2, wiki_page3.parent
    assert_equal nil, wiki_page4.parent
    assert_equal 2, wiki_page.position
    assert_equal 0, wiki_page1.position
    assert_equal 1, wiki_page2.position
    assert_equal 0, wiki_page3.position
    assert_equal 1, wiki_page4.position
  end

  test 'it has many pages that should be deleted when wiki is destroyed' do
    project = Project.create(name: 'Rorganize test', is_public: true)
    wiki = Wiki.create(project_id: project.id)
    pages = []
    pages << WikiPage.create(title: 'My title', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    pages << WikiPage.create(title: 'My title 1', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    pages << WikiPage.create(title: 'My title 2', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    pages << WikiPage.create(title: 'My title 3', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    pages << WikiPage.create(title: 'My title 4', author_id: User.current.id, content: 'content', wiki_id: wiki.id)

    home_page = WikiPage.create(title: 'Home page', author_id: User.current.id, content: 'content', wiki_id: wiki.id)
    pages << home_page
    wiki.home_page = home_page
    assert wiki.save, wiki.errors.messages
    pages.each(&:reload)
    assert_match_array pages, wiki.pages.to_a
    assert_equal home_page, wiki.home_page

    wiki.destroy
    assert_raise(ActiveRecord::RecordNotFound) {pages.each(&:reload)}
    assert_raise(ActiveRecord::RecordNotFound) {home_page.reload}
  end
end