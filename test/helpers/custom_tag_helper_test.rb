# Author: Nicolas Meylan
# Date: 22.02.15 19:41
# Encoding: UTF-8
# File: custom_tag_helper_test.rb
require 'test_helper'
module Rorganize
  module Helpers
    class CustomTagHelperTest < Rorganize::Helpers::TestCase
      test 'it builds a box header without block' do
        node(box_header_tag('Title', 'small-header'))
        assert_select 'div.small-header', 1
        assert_select 'h2', text: 'Title'
      end

      test 'it builds a box header with a block' do
        node(box_header_tag('Title', &Proc.new { link_to 'link', '#' }))
        assert_select 'div.header', 1
        assert_select 'h2', text: 'Title'
        assert_select 'div.right.actions'
        assert_select 'a', text: 'link'
      end

      test 'it builds a info tag without options' do
        node(info_tag("This is an information : don't talk to strangers"))
        assert_select 'span[title=?]', "This is an information : don't talk to strangers"
        assert_select '.octicon-info', 1
      end

      test 'it builds a info tag with options' do
        node(info_tag("This is an information : don't talk to strangers", {id: 'my-id'}))
        assert_select 'span#my-id', 1
        assert_select 'span[title=?]', "This is an information : don't talk to strangers"
        assert_select '.octicon-info', 1
      end

      test 'it builds a normal glyph' do
        node(content_tag :span, glyph('glyph content', 'info'))
        assert_select 'span', 2
        assert_select '.octicon.octicon-info', 1
        assert_select 'span', text: 'glyph content'
      end

      test 'it builds a medium glyph' do
        node(content_tag :span, medium_glyph('glyph content', 'info'))
        assert_select 'span', 2
        assert_select '.medium-octicon.octicon-info', 1
        assert_select 'span', text: 'glyph content'
      end

      test 'it builds a mega glyph' do
        node(content_tag :span, mega_glyph('glyph content', 'info'))
        assert_select 'span', 2
        assert_select '.mega-octicon.octicon-info', 1
        assert_select 'span', text: 'glyph content'
      end

      test 'it builds a glyph if condition result is true' do
        node(content_tag :span, conditional_glyph('glyph content', 1==1, 'info'))
        assert_select 'span', 2
        assert_select '.octicon.octicon-info', 1
        assert_select 'span', text: 'glyph content'
      end

      test 'it do not builds a glyph if condition result is false' do
        node(content_tag :span, conditional_glyph('glyph content', 1==2, 'info'))
        assert_select 'span', 1
        assert_select 'span', text: 'glyph content'
      end

      test 'it builds a sidebar counter' do
        node(sidebar_count_tag(20))
        assert_select 'span.count', 1
        assert_select 'span', text: '20'
      end

      test 'it builds a color field tag' do
        node(form_for('object', {url: 'link_to_form'}) { |f| color_field_tag(f, 'color') })
        assert_select 'input[type=text].color-editor-field', 1
        assert_select 'input[type=text][maxlength=?]', '7'
      end

      test 'it builds a clear both div' do
        node(clear_both)
        assert_select 'div.clear-both', 1
      end

      test 'it builds a no data render with a glyph' do
        node(no_data('There is no issues to display', 'issue', 'true'))
        assert_select 'div.no-data.large', 1
        assert_select '.octicon.octicon-issue', 1
        assert_select 'h3', 'There is no issues to display'
      end

      test 'it builds a no data render without glyph' do
        node(no_data('There is no issues to display'))
        assert_select 'div.no-data', 1
        assert_select '.octicon', 0
        assert_select 'h3', 'There is no issues to display'
      end
    end
  end
end