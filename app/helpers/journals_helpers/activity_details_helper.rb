# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: activity_helper.rb
module JournalsHelpers
  module ActivityDetailsHelper
    # Build a render for activities detail.
    # @param [Array] activities containing Journal or Comment.
    # @param [Numeric] nth : the number of the activity to render for the same day.
    def activity_detail_render(activities, nth)
      concat first_activity_detail_render(activities)
      if activities.size - 1 > 0
        concat more_activities_link
        concat more_activities_render(activities)
      end
    end

    def more_activities_render(activities)
      content_tag :div, class: 'journal-details hide more' do
        i = 0
        activities.each do |activity|
          concat more_details_render(activity) unless i == 0
          i += 1
        end
      end
    end

    def more_details_render(activity)
      content_tag :div, class: 'detail more' do
        concat content_tag :span, class: 'date', &Proc.new {
                                  concat activity.display_creation_at
                                }
        concat activity.render_details
      end
    end

    def more_activities_link
      link_to 'view more', '#', {class: 'toggle'}
    end

    def first_activity_detail_render(activities)
      first_activity = activities[0]
      content_tag :div, class: 'journal-details' do
        content_tag :ul do
          first_activity.details.collect { |detail| history_detail_render(detail, true) }.join.html_safe if first_activity.is_a?(Journal)
        end
      end
    end

    # Build a render for journal detail.
    # @param [JournalDetail] detail.
    def activity_history_detail_render(detail)
      if render_deleted_attribute?(detail)
        tree_render_deleted_attribute(detail)
      elsif render_changed_attribute?(detail)
        tree_render_changed_attribute(detail)
      else
        tree_render_affected_attribute(detail)
      end
    end

    def tree_render_deleted_attribute(detail)
      content_tag :li do
        concat "#{t(:text_deleted)} "
        concat content_tag :b, "#{property_name(detail)} "
        concat history_detail_value_render(detail, detail.old_value)
      end
    end

    def tree_render_changed_attribute(detail)
      content_tag :li do
        concat t(:text_changed)
        concat content_tag :b, " #{property_name(detail)} "
        concat "#{t(:text_from)} "
        concat history_detail_value_render(detail, detail.old_value)
        concat " #{t(:text_to)} "
        concat history_detail_value_render(detail, detail.value)
      end
    end

    def tree_render_affected_attribute(detail)
      content_tag :li do
        concat content_tag :b, "#{property_name(detail)} "
        concat "#{t(:text_set_at)} "
        concat history_detail_value_render(detail, detail.value)
      end
    end

  end
end