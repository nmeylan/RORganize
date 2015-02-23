# Author: Nicolas Meylan
# Date: 23.02.15 14:44
# Encoding: UTF-8
# File: dropdown_tag_helper_test.rb
require 'test_helper'

module Rorganize
  module Helpers
    class DropdownTagHelperTest < Rorganize::Helpers::TestCase

      test 'it builds a dropdown menu with a given raw html content' do
        node(dropdown_tag('<li>Menu 1</li><li>Menu 2</li>', :div))
        assert_dropdown
      end

      test 'it builds a dropdown menu with a given html safe content' do
        node(dropdown_tag((concat content_tag :li, 'Menu 1'; concat content_tag :li, 'Menu 2'), :div))
        assert_dropdown
      end

      test 'it builds a dropdown menu with a given dropdown rows content with' do
        node(dropdown_tag((concat dropdown_row('Menu 1'); concat dropdown_row('Menu 2')), :div))
        assert_dropdown
      end

      test 'it builds a menu with a block content' do
        node(dropdown_tag(nil, :div, &Proc.new{concat content_tag :li, 'Menu 1'; concat content_tag :li, 'Menu 2'}))
        assert_dropdown
      end

      test 'it builds a menu with a block content and dropdown rows' do
        node(dropdown_tag(nil, :div, &Proc.new{concat dropdown_row('Menu 1'); concat dropdown_row('Menu 2')}))
        assert_dropdown
      end

      test 'it builds dropdown row with a given content' do
        node(dropdown_row('Menu 1'))
        assert_select 'li', 1
        assert_select 'li', text: 'Menu 1'
      end

      test 'it builds dropdown row with a given block' do
        node(dropdown_row(&Proc.new{content_tag :span, 'Menu 1'}))
        assert_select 'li', 1
        assert_select 'span', 1
        assert_select 'span', text: 'Menu 1'
      end

      private
      def assert_dropdown
        assert_select 'div.dropdown', 1
        assert_select 'a.dropdown-link', 1
        assert_select 'a.dropdown-link[data-toggle=?]', 'dropdown'
        assert_select 'span.dropdown-caret', 1
        assert_select 'div.dropdown-menu-content', 1
        assert_select 'ul.dropdown-menu' do
          assert_select 'li', 2
          assert_select 'li', 'Menu 1'
          assert_select 'li', 'Menu 2'
        end
      end
    end
  end
end