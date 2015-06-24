# Author: Nicolas Meylan
# Date: 21.02.15 16:08
# Encoding: UTF-8
# File: application_helper_test.rb
require 'test_helper'

class ApplicationHelperTest < Rorganize::Helpers::TestCase

  test "it detects if sidebar has content" do
    assert_not sidebar_content?
    content_for :sidebar, '<ul><li>Sidebar element</li></ul>'
    assert sidebar_content?
  end

  test "it builds a javascript tag when object contains errors" do
    errors = ["Name cannot be blank", "Password should contains at least 4 characters"]
    result = error_messages(errors)
    node(result)
    assert_select 'script', 1
    assert_not_empty result.scan(/<!\[CDATA\[\nerrorExplanation/)
    assert_not_empty result.scan(/<li>(Name cannot be blank)<\/li>/)
    assert_not_empty result.scan(/<li>(Password should contains at least 4 characters)<\/li>/)
  end

  test "it does not builds a javascript tag when object does not contains errors" do
    errors = []
    result = error_messages(errors)
    assert_nil result
  end

  test "it builds a select tag with grouped options for project versions" do
    versions = []
    versions << Version.new(name: 'Opened version', description: '', start_date: Date.new(2015, 02, 21), target_date: Date.new(2015, 03, 23), project_id: 1)
    versions << Version.new(name: 'Done version', description: '', start_date: Date.new(2012, 02, 23), project_id: 1, is_done: true)
    node(select_tag_versions(versions, 'versions_select_tag', 'versions_select_tag', nil))
    assert_select '#versions_select_tag', 1
    assert_select 'optgroup', 2
    assert_select 'option', 3
    assert_select 'option', text: 'Opened version'
    assert_select 'option', text: 'Done version'
    assert_select 'option[data-version_info]', 2
    assert_select 'option[data-target_date]', 1
    assert_select 'option[data-start_date]', 2
  end

  test "it builds a version info string that indicate version bounds" do
    version = Version.new(name: 'Opened version', description: '', start_date: Date.new(2015, 02, 21), target_date: Date.new(2015, 03, 02), project_id: 1)
    node(build_version_info(version))
    assert_select 'b', 2
    assert_select 'b', text: '21 Feb. 2015'
    assert_select 'b', text: '02 Mar. 2015'
  end

  test "it builds a version info string that indicate version bounds without target date" do
    version = Version.new(name: 'Opened version', description: '', start_date: Date.new(2015, 02, 21), project_id: 1)
    node(build_version_info(version))
    assert_select 'b', 2
    assert_select 'b', text: '21 Feb. 2015'
    assert_select 'b', text: I18n.t(:text_undetermined)
  end

  test "it build a contextual with title without block" do
    contextual('My title')
    node(content_for(:contextual))
    assert_select 'h1', text: 'My title'
  end

  test "it builds a contextual with title with a block" do
    contextual 'My title' do
      link_to 'This is awesome', "http://www.rorganize.org"
    end
    node(content_for(:contextual))
    assert_select 'h1', text: 'My title'
    assert_select '.splitcontentright', 1
    assert_select 'a', text: 'This is awesome'
    assert_select 'a[href=?]', "http://www.rorganize.org"
  end

  test "it builds a contextual just with a block" do
    contextual do
      link_to 'This is awesome', "http://www.rorganize.org"
    end
    node(content_for(:contextual))
    assert_select 'h1', 0
    assert_select 'a', text: 'This is awesome'
    assert_select 'a[href=?]', "http://www.rorganize.org"
  end

  test "it builds a breadcrumb div" do
    node(breadcrumb('This is my breadcrumb'))
    assert_select '.breadcrumb', 1
  end

  test "it displays comment presence indicator when comment number is greater than 0" do
    node(comment_presence(2))
    assert_select '.smooth-gray', 0
    assert_select '.octicon.octicon-comment', 1
    assert_select 'span', text: '2'
  end

  test "it do not display comment presence indicator when comment number is equal to 0" do
    node(comment_presence(0))
    assert_select '.smooth-gray', 1
    assert_select '.octicon.octicon-comment', 1
    assert_select 'span', text: '0'
  end

  test "it resize text when length is greater than the given one" do
    assert_equal 'abcdefgh', resize_text('abcdefgh', 9)
    assert_equal 'abcdef...', resize_text('abcdefgh', 5)
  end

  test "it should display white foreground color on dark background" do
    assert_equal 'background-color:#eb6420; color:white', style_background_color('#eb6420')
    assert_equal 'background-color:#6cc644; color:white', style_background_color('#6cc644')
    assert_equal 'background-color:#207de5; color:white', style_background_color('#207de5')
    assert_equal 'background-color:#5319e7; color:white', style_background_color('#5319e7')
    assert_equal 'background-color:#0052cc; color:white', style_background_color('#0052cc')
    assert_equal 'background-color:#006b75; color:white', style_background_color('#006b75')
  end

  test "it should display black foreground color on light background" do
    assert_equal 'background-color:#fbca04; color:#484848', style_background_color('#fbca04')
    assert_equal 'background-color:#f7c6c7; color:#484848', style_background_color('#f7c6c7')
    assert_equal 'background-color:#fef2c0; color:#484848', style_background_color('#fef2c0')
    assert_equal 'background-color:#fad8c7; color:#484848', style_background_color('#fad8c7')
    assert_equal 'background-color:#bfe5bf; color:#484848', style_background_color('#bfe5bf')
    assert_equal 'background-color:#d4c5f9; color:#484848', style_background_color('#d4c5f9')
    assert_equal 'background-color:#c7def8; color:#484848', style_background_color('#c7def8')
    assert_equal 'background-color:#bfd4f2; color:#484848', style_background_color('#bfd4f2')
  end
end