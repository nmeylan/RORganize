# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: history_helper.rb
module Rorganize
  module Helpers
    module HistoryHelper

      # Build a generic history for journalizable models.
      # @param [History] history : object.
      def history_render(history) #If come from show action
        concat content_tag :div, nil, class: 'separator'
        concat content_tag :h2, t(:label_history)
        concat history_blocks_render(history)
      end

      def history_blocks_render(history)
        content_tag :div, id: 'history-blocks', &Proc.new {
          history.content.collect do |activity|
            select_history_renderer(activity)
          end.join.html_safe
        }
      end

      def select_history_renderer(activity)
        if activity.is_a?(Journal)
          history_block_render(activity).html_safe
        else
          comment_block_render(activity, nil, false).html_safe
        end
      end

      # Build a history block for one Journal.
      # @param [Journal] journal : to render.
      def history_block_render(journal)
        content_tag :div, {class: 'history-block', id: "journal-#{journal.id}"} do
          concat journal.display_author_avatar
          concat histoy_block_header(journal)
          concat clear_both
          concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
        end
      end

      def histoy_block_header(journal)
        user = journal.display_author(false)
        content_tag :div, class: "history-header #{'display-avatar' if journal.user_avatar?}" do
          concat content_tag :span, user, {class: 'author'}
          concat " #{t(:label_updated).downcase} #{t(:text_this)} "
          concat "#{distance_of_time_in_words(journal.created_at, Time.now)} #{t(:label_ago)}. "
          concat content_tag :span, journal.created_at.strftime(Rorganize::TIME_FORMAT), {class: 'history-date'}
        end
      end

      # Build a history detail block.
      # @param [JournalDetail] detail to render.
      # @param [Boolean] no_icon : if true don't display for the updated field, else display the icon. Rendered icons are depending of the object's updated field.
      # for the list of icons @see Rorganize::ACTION_ICON.
      def history_detail_render(detail, no_icon = false, enhanced_detail_render = true)
        content_tag :li do
          icon = Rorganize::ACTION_ICON[detail.property_key.to_sym]
          icon ||= 'pencil'
          concat content_tag :span, nil, class: "octicon octicon-#{icon} activity-icon" unless no_icon
          concat select_detail_renderer(detail)
        end
      end

      # Select the right renderer to use.
      # @param [JournalDetail] detail to render.
      def select_detail_renderer(detail)
        content_tag :span, class: 'detail' do
          if render_deleted_attribute?(detail)
            render_deleted_attribute(detail)
          elsif render_changed_attribute?(detail)
            render_changed_attribute(detail)
          else
            render_affected_attribute(detail)
          end
        end
      end

      # build a render for affected attribute (old_value: nil)
      # @param [JournalDetail] detail to render.
      def render_affected_attribute(detail)
        concat content_tag :b, "#{detail.property} "
        concat "#{t(:text_set_at)} "
        concat history_detail_value_render(detail, detail.value)
      end

      # build a render for changed attribute (old_value = value: not nil)
      # @param [JournalDetail] detail to render.
      def render_changed_attribute(detail)
        concat content_tag :b, "#{detail.property} #{t(:text_changed)} "
        concat "#{t(:text_from)} "
        concat history_detail_value_render(detail, detail.old_value)
        concat " #{t(:text_to)} "
        concat history_detail_value_render(detail, detail.value)
      end

      # build a render for delete attribute (old_value: not nil, value: nil)
      # @param [JournalDetail] detail to render.
      def render_deleted_attribute(detail)
        concat content_tag :b, "#{detail.property} "
        concat history_detail_value_render(detail, detail.old_value)
        concat " #{t(:text_deleted)}"
      end

      def render_changed_attribute?(detail)
        detail.old_value && detail.value && !detail.old_value.blank? && !detail.value.blank?
      end

      def render_deleted_attribute?(detail)
        detail.old_value && (detail.value.nil? || detail.value.eql?(''))
      end

      # @param [JournalDetail] detail the journal detail.
      # @param [String] value : content to render.
      # @param [Boolean] enhanced_detail_render : if we use the enhanced detail render or not.
      # Enhanced detail mean a render with nice color and style. (false in case of email notification)
      # @param [Hash] options
      def history_detail_value_render(detail, value, enhanced_detail_render = true, options = {})
        truncated_value = resize_text(value, 35)
        if enhanced_detail_render
          case detail.property_key
            when 'status_id'
              color = Rorganize::Managers::IssueStatusesColorManager.colors[value]
              color ||= '#333333'
              content_tag :b, value, {class: 'issue-status issue-status-small',
                                      style: "#{style_background_color(color)}"}
            when 'assigned_to_id'
              fast_profile_link(value)
            when 'category_id'
              content_tag :b, glyph(value, 'tag'), {class: 'info-square info-square-small'}
            when 'version_id'
              content_tag :b, glyph(value, 'milestone'), {class: 'info-square info-square-small'}
            else
              content_tag :b, "#{truncated_value} "
          end
        else
          content_tag :b, "#{truncated_value} "
        end
      end
    end
  end
end