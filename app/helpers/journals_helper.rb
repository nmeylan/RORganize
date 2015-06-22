# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: journals_helper.rb

module JournalsHelper
  include JournalsHelpers::ActivityHelper
  include JournalsHelpers::ActivityDetailsHelper
  include JournalsHelpers::ActivitySidebarHelper
  # Build a render for activities.
  # @param [Activities] activities object.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
  def display_activities(activities, to, from)
    content_tag :div, data: {role: "activities"} do
      concat activities_range(to, from)
      concat render_all_activities(activities)
    end
  end

  def render_all_activities(activities)
    content_tag :div, class: 'activities' do
      if activities.content.to_a.any?
        activities.content.each do |date, objects|
          render_activities_for_date(activities, date, objects)
        end
      else
        no_data(t(:text_no_activities), 'rss', true)
      end
    end
  end

  # Build a render for activities that occurred at the given date.
  # @param [Activities] activities.
  # @param [Date] date.
  # @param [Hash] objects a hash with this structure : {type_id: ['journalizable', 'journalizable', 'comment', 'journalizable']}
  def render_activities_for_date(activities, date, objects)
    concat activities_date(date)
    concat content_tag :div, class: 'journals', &Proc.new {
      activities_render(activities, date, objects)
    }
    concat clear_both
  end

  # Build a render of the date range of activities.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
  def activities_range(to, from)
    content_tag :div, {class: 'activities-range'} do
      concat "#{t(:text_from).capitalize} "
      concat content_tag :span, from
      concat " #{t(:text_to)} "
      concat content_tag :span, to
      concat '.'
    end
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
        concat activity_render(act, act[0], i)
      else
        concat content_tag :div, 'latest 1000 activities from this day were loaded.', {class: 'activity max'}
        break
      end
      i += 1
    end
  end


end