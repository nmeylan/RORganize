# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: activity_helper.rb
module Rorganize
  module Helpers
    module JournalsHelpers
      module ActivityHelper
        include JournalsHelpers::ActivityDetailsHelper
        # Build a render for one journalizable for same journalizable items. if two or more journals exists for one item the same day,
        # they will be compact into one.
        # @param [Array] activities containing Journal or Comment.
        # @param [Journal|Comment] activity : the activity to render.
        # @param [Numeric] nth : the number of the activity to render for the same day.
        def activity_render(activities, activity, nth)
          content_tag :div, class: "activity #{nth % 2 == 0 ? 'odd' : 'even'}", &Proc.new {
            content_tag :p do
              select_right_activity_renderer(activity, nth)
              activity_detail_render(activities, nth)
            end
          }
        end

        def select_right_activity_renderer(activity, nth)
          if activity.is_a?(Journal)
            journal_header_render(activity, nth)
          elsif activity.is_a?(Comment)
            comment_header_render(activity, nth)
          end
        end

        # Build a render for journalizable content.
        # @param [Journal] journal.
        # @param [Numeric] nth : the number of the activity to render for the same day.
        def journal_header_render(journal, nth)
          user = journal.display_author
          if nth % 2 == 0 #Render is depending on the parity
            safe_concat journal_icon_render(journal)
            safe_concat activity_author_render(user)
            safe_concat journal_action_type_render(journal)
            safe_concat journal_object_type_render(journal)
            journal.display_project_link(@project)
            safe_concat activity_date_render(journal)
          else
            safe_concat journal_icon_render(journal)
            safe_concat activity_date_render(journal)
            safe_concat activity_author_render(user)
            safe_concat journal_action_type_render(journal)
            safe_concat journal_object_type_render(journal)
            journal.display_project_link(@project)
          end
        end

        def journal_object_type_render(journal)
          content_tag :span, journal.display_object_type, class: 'object-type'
        end

        def journal_action_type_render(journal)
          content_tag :span, journal.display_action_type, class: 'action-type'
        end

        def activity_date_render(journal)
          content_tag :span, journal.display_creation_at, class: 'date'
        end

        def activity_author_render(user)
          content_tag :span, user, class: 'author'
        end

        def journal_icon_render(journal)
          content_tag :span, nil, class: "#{journal.display_action_type_icon}"
        end

        # Build a render for journalizable content.
        # @param [Comment] comment.
        # @param [Numeric] nth : the number of the activity to render for the same day.
        def comment_header_render(comment, nth)
          if nth % 2 == 0 #Render is depending on the parity
            safe_concat comment_icon_render
            safe_concat activity_author_render(comment.display_author)
            safe_concat comment.render_header
            comment.display_project_link(@project)
            safe_concat activity_date_render(comment)
          else
            safe_concat comment_icon_render
            safe_concat activity_date_render(comment)
            safe_concat activity_author_render(comment.display_author)
            safe_concat comment.render_header
            comment.display_project_link(@project)
          end
        end

        def comment_icon_render
          content_tag :span, nil, class: 'octicon octicon-comment activity-icon'
        end
      end
    end
  end
end