# Author: Nicolas Meylan
# Date: 22.02.15 18:36
# Encoding: UTF-8
# File: collection_helper_test.rb
require 'test_helper'

module Rorganize
  module Helpers

    class CollectionHelperTest < Rorganize::Helpers::TestCase
      include WillPaginate::ViewHelpers

      test 'it builds a pagination for the given collection' do
        collection = []
        50.times { collection << 'element' }
        session = {per_page: 25}
        path = 'path_to_index'
        self.stubs(:will_paginate).returns('<div class="pagination"><span class="previous_page disabled">Previous</span> <em class="current">1</em> <a rel="next" data-remote="true" href="/projects/rorganize/issues?page=2">2</a><a class="next_page" data-remote="true" rel="next" href="/projects/rorganize/issues?page=2">Next</a></div>'.html_safe)

        node(concat(paginate(collection, session, path)))
        assert_select 'div.per-page', 1
        assert_select 'label.per-page', text: I18n.t(:label_per_page)
        assert_select '.pagination', 1
        assert_select 'a', 2
        assert_select 'select#per-page', 1
        assert_select 'select[data-link=?]', 'path_to_index'
      end

      test 'it build a sortable link for lists when column is not the sorted one' do
        self.stubs(:sort_column).returns('test.id')
        self.stubs(:url_for).returns('path_to_index')
        node(sortable('test.name', 'Name'))
        assert_select 'a', 1
        assert_select '.octicon-triangle-up', 0
        assert_select '.octicon-triangle-down', 0
      end

      test 'it build a sortable link for lists when column is the sorted one in asc order' do
        self.stubs(:sort_column).returns('test.name')
        self.stubs(:sort_direction).returns('asc')
        self.stubs(:url_for).returns('path_to_index')
        node(sortable('test.name', 'Name'))
        assert_select 'a', 1
        assert_select '.octicon-triangle-up', 1
        assert_select '.octicon-triangle-down', 0
      end

      test 'it build a sortable link for lists when column is the sorted one in desc order' do
        self.stubs(:sort_column).returns('test.name')
        self.stubs(:sort_direction).returns('desc')
        self.stubs(:url_for).returns('path_to_index')
        node(sortable('test.name', 'Name'))
        assert_select 'a', 1
        assert_select '.octicon-triangle-up', 0
        assert_select '.octicon-triangle-down', 1
      end

    end
  end
end