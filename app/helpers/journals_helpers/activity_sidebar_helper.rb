# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: activity_helper.rb

module JournalsHelpers
  module ActivitySidebarHelper
    # Build a render for the activities' sidebar.
    # @param [String] types : class name of Journalizable items.
    # @param [Array] selected_types : selected types.
    # @param [String] period : a value included in (ONE_DAY, THREE_DAYS, ONE_WEEK).
    # @param [Date] date : the selected date.
    # @param [User] user : provide when the sidebar is used in profile panel.
    def sidebar_types_selection(types, selected_types, period, date, user = nil)
      periods = {ONE_DAY: t(:label_activity_period_one_day), THREE_DAYS: t(:label_activity_period_three_days), ONE_WEEK: t(:label_activity_period_one_week)}
      select_values = Hash[Journal::ACTIVITIES_PERIODS.keys.map { |period| [periods[period], period] }]
      project_id = @project_decorator ? @project_decorator.slug : nil
      form_tag url_for({action: 'activity_filter', project_id: project_id, user: user}), {id: 'activities-filter', remote: true, data: {role: "activities-filter"}} do
        concat sidebar_activity_type_choice(selected_types, types)
        sidebar_activity_period_choice(date, period, select_values)
      end
    end

    # Build the render for the activity period form's part. (combobox  and date_field)
    def sidebar_activity_period_choice(date, period, select_values)
      concat date_field_tag 'date', date, {class: 'filter-selection'}
      concat content_tag :div, {class: 'autocomplete-combobox cbb-tiny nosearch', id: 'period-select'}, &Proc.new {
                               select_tag 'period', options_for_select(select_values, period),
                                          {include_blank: false, class: 'filter-selection chzn-select-deselect cbb-tiny'}
                             }
    end

    # Build the render for activity types choice. (e.g : issues, documents, wiki pages ...s)
    def sidebar_activity_type_choice(selected_types, types)
      content_tag :ul, class: '' do
        types.collect do |type|
          content_tag :li, class: 'activities-filter' do
            concat check_box_tag "[types][#{type}]", 1, selected_types.include?(type), {class: 'filter-selection'}
            concat label_tag "[types][#{type}]", Rorganize::Utils::class_name_to_human_name(type), {class: ''}
          end
        end.join.html_safe
      end
    end
  end
end