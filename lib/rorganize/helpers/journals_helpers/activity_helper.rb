# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: activity_helper.rb
module Rorganize
  module Helpers
    module JournalsHelpers
      module ActivityHelper
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

        # Build the right activity header.
        # @param [Journal|Comment] activity : the activity to render.
        # @param [Numeric] nth : the number of the activity to render for the same day.
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
            concat journal_icon_render(journal)
            concat activity_author_render(user)
            concat journal_action_type_render(journal)
            concat journal_object_type_render(journal)
            concat journal.display_project_link(@project)
            concat activity_date_render(journal)
          else
            concat journal_icon_render(journal)
            concat activity_date_render(journal)
            concat activity_author_render(user)
            concat journal_action_type_render(journal)
            concat journal_object_type_render(journal)
            concat journal.display_project_link(@project)
          end
        end

        # Render the journal object type.
        def journal_object_type_render(journal)
          content_tag :span, journal.display_object_type, class: 'object-type'
        end

        # Render the journal action type.
        def journal_action_type_render(journal)
          content_tag :span, journal.display_action_type, class: 'action-type'
        end

        # Render the activity time.
        def activity_date_render(journal)
          content_tag :span, journal.display_creation_at, class: 'date'
        end

        # Render the activity's author.
        def activity_author_render(user)
          content_tag :span, user, class: 'author'
        end

        # Render the icon related to the journal.
        def journal_icon_render(journal)
          content_tag :span, nil, class: "#{journal.display_action_type_icon}"
        end

        # Build a render for journalizable content.
        # @param [Comment] comment.
        # @param [Numeric] nth : the number of the activity to render for the same day.
        def comment_header_render(comment, nth)
          if nth % 2 == 0 #Render is depending on the parity
            concat comment_icon_render
            concat activity_author_render(comment.display_author)
            concat comment.render_header
            concat comment.display_project_link(@project)
            concat activity_date_render(comment)
          else
            concat comment_icon_render
            concat activity_date_render(comment)
            concat activity_author_render(comment.display_author)
            concat comment.render_header
            concat comment.display_project_link(@project)
          end
        end

        # Render the comment icon.
        def comment_icon_render
          content_tag :span, nil, class: 'octicon octicon-comment activity-icon'
        end
      end
    end
  end
end