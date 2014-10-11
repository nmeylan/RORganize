# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: history_helper.rb

module HistoryHelper
# Build a history block for one Journal.
# @param [Journal] journal : to render.
  def history_block_render(journal)
    content_tag :div, {class: 'history-block', id: "journal-#{journal.id}"} do
      safe_concat journal.display_author_avatar
      safe_concat histoy_block_header(journal)
      safe_concat clear_both
      safe_concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
    end
  end

  def histoy_block_header(journal)
    user = journal.display_author(false)
    content_tag :div, class: "history-header #{'display-avatar' if journal.user_avatar?}" do
      safe_concat content_tag :span, user, {class: 'author'}
      safe_concat " #{t(:label_updated).downcase} #{t(:text_this)} "
      safe_concat "#{distance_of_time_in_words(journal.created_at, Time.now)} #{t(:label_ago)}. "
      safe_concat content_tag :span, journal.created_at.strftime(Rorganize::TIME_FORMAT), {class: 'history-date'}
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
      safe_concat content_tag :span, nil, class: "octicon octicon-#{icon} activity-icon" unless no_icon
      safe_concat select_detail_renderer(detail)
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
    safe_concat content_tag :b, "#{detail.property} "
    safe_concat "#{t(:text_set_at)} "
    safe_concat history_detail_value_render(detail, detail.value)
  end

  # build a render for changed attribute (old_value = value: not nil)
  # @param [JournalDetail] detail to render.
  def render_changed_attribute(detail)
    safe_concat content_tag :b, "#{detail.property} #{t(:text_changed)} "
    safe_concat "#{t(:text_from)} "
    safe_concat history_detail_value_render(detail, detail.old_value)
    safe_concat " #{t(:text_to)} "
    safe_concat history_detail_value_render(detail, detail.value)
  end

  # build a render for delete attribute (old_value: not nil, value: nil)
  # @param [JournalDetail] detail to render.
  def render_deleted_attribute(detail)
    safe_concat content_tag :b, "#{detail.property} "
    safe_concat history_detail_value_render(detail, detail.old_value)
    safe_concat " #{t(:text_deleted)}"
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
          content_tag :b, value, {class: 'issue-status issue-status-small',
                                  style: "background-color: #{Rorganize::Managers::IssueStatusesColorManager.colors[value]}"}
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