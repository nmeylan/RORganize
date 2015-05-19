# Author: Nicolas Meylan
# Date: 23.02.15 15:51
# Encoding: UTF-8
# File: filter_helper_test.rb
require 'test_helper'

module Rorganize
  module Helpers
    class FilterHelperTest < Rorganize::Helpers::TestCase
      test 'it builds radio buttons' do
        buttons = %w(open close equal not\ equal)
        node(generics_filter_radio_button('status', buttons))
        assert_select 'span', 1

        assert_select 'label', 4
        assert_select 'label', text: 'Open'
        assert_select 'label', text: 'Close'
        assert_select 'label', text: 'Equal'
        assert_select 'label', text: 'Not equal'

        assert_select 'input[type=radio]', 4
        assert_select 'input[type=radio][name="filter[status][operator]"]', 4
        assert_select 'input[type=radio].status', 4
        assert_select 'input[type=radio]#status_open', 1
        assert_select 'input[type=radio]#status_close', 1
        assert_select 'input[type=radio]#status_equal', 1
        assert_select 'input[type=radio]#status_not_equal', 1
      end

      test 'it builds a filter date field' do
        node(generics_filter_date_field('created_at'))

        assert_select 'input[type=date]', 1
        assert_select 'input[type=date][name="filter[created_at][value]"]', 1
        assert_select 'input[type=date].calendar', 1
      end

      test 'it builds a filter text field' do
        node(generics_filter_text_field('subject'))

        assert_select 'input[type=text]', 1
        assert_select 'input[type=text][name="filter[subject][value]"]', 1
        assert_select 'input[type=text][size=?]', '80'
      end

      test 'it builds a filter select field' do
        node(generics_filter_simple_select('author', %w(Nicolas James Sean Alex Boris)))

        assert_select 'select', 1
        assert_select 'select.chzn-select.cbb-large', 1
        assert_select 'select#author_list', 1
        assert_select 'select[multiple=?]', 'multiple'
        assert_select 'option', 5
        assert_select 'option', text: 'Nicolas'
        assert_select 'option', text: 'James'
        assert_select 'option', text: 'Sean'
        assert_select 'option', text: 'Alex'
        assert_select 'option', text: 'Boris'
      end

      test 'it builds a polymorphic filter for a simple select type' do
        node(generic_filter(:simple_select, 'Author', 'author', %w(all equal not\ equal), %w(Nicolas James Sean Alex Boris)))

        assert_select 'input[type=radio]', 3
        assert_select 'input[type=radio][name="filter[author][operator]"]', 3
        assert_select 'input[type=radio].author', 3
        assert_select 'input[type=radio]#author_all', 1
        assert_select 'input[type=radio]#author_equal', 1
        assert_select 'input[type=radio]#author_not_equal', 1


        assert_select 'select', 1
        assert_select 'select.chzn-select.cbb-large', 1
        assert_select 'select#author_list', 1
        assert_select 'select[multiple=?]', 'multiple'
        assert_select 'option', 5
        assert_select 'option', text: 'Nicolas'
        assert_select 'option', text: 'James'
        assert_select 'option', text: 'Sean'
        assert_select 'option', text: 'Alex'
        assert_select 'option', text: 'Boris'
      end

      test 'it builds a polymorphic filter for a date type' do
        node(generic_filter(:date, 'Created at', 'created_at', %w(all today superior inferior equal)))

        assert_select 'input[type=radio]', 5
        assert_select 'input[type=radio][name="filter[created_at][operator]"]', 5
        assert_select 'input[type=radio].created_at', 5
        assert_select 'input[type=radio]#created_at_all', 1
        assert_select 'input[type=radio]#created_at_today', 1
        assert_select 'input[type=radio]#created_at_superior', 1
        assert_select 'input[type=radio]#created_at_inferior', 1
        assert_select 'input[type=radio]#created_at_equal', 1

        assert_select 'input[type=date]', 1
        assert_select 'input[type=date][name="filter[created_at][value]"]', 1
        assert_select 'input[type=date].calendar', 1
      end

      test 'it builds a polymorphic filter for a text type' do
        node(generic_filter(:text, 'Subject', 'subject', %w(all contains not\ contains)))

        assert_select 'input[type=radio]', 3
        assert_select 'input[type=radio][name="filter[subject][operator]"]', 3
        assert_select 'input[type=radio].subject', 3
        assert_select 'input[type=radio]#subject_all', 1
        assert_select 'input[type=radio]#subject_contains', 1
        assert_select 'input[type=radio]#subject_not_contains', 1

        assert_select 'input[type=text]', 1
        assert_select 'input[type=text][name="filter[subject][value]"]', 1
        assert_select 'input[type=text][size=?]', '80'
      end

      test 'it should raise an exception when filter type is undefined' do
        assert_raises(Exception) { generic_filter(:undefined, 'Subject', 'subject', %w(all contains not\ contains)) }
      end

      test 'it builds a filter choice bar' do
        node(content_tag :div, &Proc.new { filter_type_choice_tag })

        assert_select 'label', 2
        assert_select 'label', text: I18n.t(:label_all)
        assert_select 'label', text: I18n.t(:link_filter)

        assert_select 'input[type=radio]', 2
        assert_select 'input[type=radio][name=type]', 2

        assert_select 'input[type=radio][value=all]', 1
        assert_select 'input[type=radio]#type-all', 1

        assert_select 'input[type=radio][value=filter]', 1
        assert_select 'input[type=radio]#type-filter', 1
      end

      test 'it builds a select field to choose which attributes should be filtered' do
        @class_name = 'Issue'
        node(filter_attribute_choice_tag(['Author', 'Status', 'Created at']))

        assert_select 'div.autocomplete-combobox', 1
        assert_select 'select#filters-list', 1
        assert_select 'option', 3
        assert_select 'option', text: 'Author'
        assert_select 'option', text: 'Status'
        assert_select 'option', text: 'Created at'
      end

      test 'it builds a save filter button when user is allowed to save queries out of query context' do
        @project = projects(:projects_001)
        User.any_instance.stubs(:allowed_to?).returns(true)

        node(save_filter_button_tag(true, {filter_content: 'my_filter', user: User.current, project: @project, type: 'Issue'}))

        assert_select 'a', 1
        assert_select 'a[href=?]', new_project_query_queries_path('rorganize', 'Issue')
      end

      test 'it builds a save filter button when user is allowed to save queries in a query context' do
        @project = projects(:projects_001)
        User.any_instance.stubs(:allowed_to?).returns(true)

        params[:query_id] = 666
        node(save_filter_button_tag(true, {filter_content: 'my_filter', user: User.current, project: @project, type: 'Issue'}))

        assert_select 'a', 1
        assert_select 'a#filter-edit-save', 1
        assert_select 'a[href=?]', edit_query_filter_queries_path(666)
        assert_select 'a[data-confirm-message=?]', I18n.t(:text_confirm_update_filter)
      end

      test 'it do not builds a save filter button when user is allowed when filter content is empty' do
        @project = projects(:projects_001)
        User.any_instance.stubs(:allowed_to?).returns(true)

        assert_nil save_filter_button_tag(true, {filter_content: '', user: User.current, project: @project, type: 'Issue'})
      end

      test 'it do not builds a save filter button when user is allowed when filter content is not provided' do
        @project = projects(:projects_001)
        User.any_instance.stubs(:allowed_to?).returns(true)

        assert_nil save_filter_button_tag(true, {user: User.current, project: @project, type: 'Issue'})
      end

      test 'it do not builds a save filter button when user is not allowed to do it' do
        @project = projects(:projects_001)
        User.any_instance.stubs(:allowed_to?).returns(false)

        assert_nil save_filter_button_tag(true, {filter_content: 'my_filter', user: User.current, project: @project, type: 'Issue'})
      end

      test 'it builds a complete filter tag' do
        filtered_attributes = ['Author', 'Status', 'Created at']
        submission_path = 'path_to_submission_handler'

        node(filter_tag('issue', filtered_attributes, submission_path, true))

        assert_select 'fieldset#issue-filter', 1
        assert_select 'legend' do
          assert_select 'a.toggle', 1
          assert_select 'a#issue', 1
        end

        assert_select 'div.content', 1
        assert_select 'form#filter-form' do
          assert_select 'table', 1
          assert_select 'input[type=submit][value=?]', I18n.t(:button_apply)
        end

      end
    end
  end
end