# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: journals_helper.rb

module JournalsHelper
  include Rorganize::Helpers::JournalsHelpers::ActivityHelper
  # Build a render for activities.
  # @param [Activities] activities object.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
  def display_activities(activities, to, from)
    activities_range(to, from) +
        (content_tag :div, class: 'activities', &Proc.new {
          if activities.content.to_a.any?
            activities.content.each do |date, objects|
              render_activities_for_date(activities, date, objects)
            end
          else
            no_data(t(:text_no_activities), 'rss', true)
          end
        })
  end

  def render_activities_for_date(activities, date, objects)
    safe_concat activities_date(date)
    safe_concat content_tag :div, class: 'journals', &Proc.new {
      activities_render(activities, date, objects)
    }
    safe_concat clear_both
  end

  # Build a render of the date range of activities.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
  def activities_range(to, from)
    content_tag :div, {class: 'activities-range'}, &Proc.new {
      safe_concat t(:text_from).capitalize + ' '
      safe_concat content_tag :span, from
      safe_concat ' ' + t(:text_to) + ' '
      safe_concat content_tag :span, to
      safe_concat '.'
    }
  end

  # Build a render of the activities date.
  # @param [Date] date.
  def activities_date(date)
    content_tag :div, class: 'date-circle' do
      content_tag :div, content_tag(:p, date.strftime('%a. %-d %b.')), class: 'inner-circle'
    end
  end

  # Build a render all journals.
  # @param [Activities] activities.
  # @param [Date] date.
  # @param [Hash] objects a hash with this structure : {type_id: ['journalizable', 'journalizable', 'comment', 'journalizable']}
  def activities_render(activities, date, objects)
    i = 0
    objects.each_key do |polymorphic_identifier|
      if i < 1000
        act = activities.content_for(date, polymorphic_identifier)
        safe_concat activity_render(act, act[0], i)
      else
        safe_concat content_tag :div, 'latest 1000 activities from this day were loaded.', {class: 'activity max'}
        break
      end
      i += 1
    end
  end


  # Build a render for the activities' sidebar.
  # @param [String] types : class name of Journalizable items.
  # @param [Array] selected_types : selected types.
  # @param [String] period : a value included in (ONE_DAY, THREE_DAYS, ONE_WEEK).
  # @param [Date] date : the selected date.
  # @param [User] user : provide when the sidebar is used in profile panel.
  def sidebar_types_selection(types, selected_types, period, date, user = nil)
    labels = {'Issue' => t(:label_activity_type_issue), 'Category' => t(:label_activity_type_category), 'Document' => t(:label_activity_type_document),
              'Member' => t(:label_activity_type_member), 'Version' => t(:label_activity_type_version), 'Wiki' => t(:label_activity_type_wiki),
              'WikiPage' => t(:label_activity_type_wiki_page)}
    periods = {ONE_DAY: t(:label_activity_period_one_day), THREE_DAYS: t(:label_activity_period_three_days), ONE_WEEK: t(:label_activity_period_one_week)}
    select_values = Hash[Journal::ACTIVITIES_PERIODS.keys.map { |period| [periods[period], period] }]
    project_id = @project_decorator ? @project_decorator.slug : nil
    form_tag url_for({action: 'activity_filter', project_id: project_id, user: user}), {id: 'activities-filter', remote: true} do
      safe_concat sidebar_activity_type_choice(labels, selected_types, types)
      sidebar_activity_period_choice(date, period, select_values)
    end
  end

  def sidebar_activity_period_choice(date, period, select_values)
    safe_concat date_field_tag 'date', date, {class: 'filter-selection'}
    safe_concat content_tag :div, {class: 'autocomplete-combobox cbb-tiny nosearch', id: 'period-select'}, &Proc.new {
      select_tag 'period', options_for_select(select_values, period),
                 {include_blank: false, class: 'filter-selection chzn-select-deselect cbb-tiny'}
    }
  end

  def sidebar_activity_type_choice(labels, selected_types, types)
    content_tag :ul, class: '' do
      types.collect do |type|
        content_tag :li, class: 'activities-filter' do
          safe_concat check_box_tag "[types][#{type}]", 1, selected_types.include?(type), {class: 'filter-selection'}
          safe_concat label_tag "[types][#{type}]", labels[type], {class: ''}
        end
      end.join.html_safe
    end
  end

end