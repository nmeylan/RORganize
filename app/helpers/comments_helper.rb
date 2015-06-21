# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_helper.rb

module CommentsHelper
  # Build a comments block(thread) render.
  # @param [Array] collection of comments.
  # @param [Comment] selected_comment : the selected comment.
  # @param [Booelan] avatar : if true display user avatar, hide avatar otherwise.
  def comments_block(collection, selected_comment = nil, avatar = true)
    content_tag :div, id: 'comments-block' do
      collection.collect do |comment|
        if selected_comment
          concat comment_block_render(comment, selected_comment.id, avatar)
        else
          concat comment_block_render(comment, nil, avatar)
        end
      end.join.html_safe
    end
  end

  # Build a single comment block render.
  # @param [Comment] comment : the comment to render.
  # @param [Object] selected_comment_id : id of the selected comment if there is.
  # @param [Booelan] avatar : if true display user avatar, hide avatar otherwise.
  def comment_block_render(comment, selected_comment_id = nil, avatar = true)
    css_class = comment.id.eql?(selected_comment_id) ? 'comment-content selected' : 'comment-content'
    content_tag :div, {id: "comment-#{comment.id}", class: 'comment-block', data: {role: "comment-block", id: comment.id}} do
      concat comment.author_avatar unless avatar
      concat comment_block_header(avatar, comment)
      concat comment_block_content(comment, css_class)
    end
  end

  def comment_block_content(comment, css_class)
    content_tag :div, class: css_class, data: {role: "comment-content", id: comment.id} do
      markdown_to_html comment.content, comment.model
    end
  end

  def comment_block_header(avatar, comment)
    content_tag :div, class: "comment-header #{'display-avatar' if comment.author_avatar?}" do
      comment_block_header_author_info(avatar, comment)
      concat content_tag :span, comment.creation_date, {class: 'history-date'}
      concat comment_block_header_edited_indicator(comment) if comment.edited?
      concat comment_block_header_actions(comment)
    end
  end

  def comment_block_header_author_info(avatar, comment)
    concat_span_tag comment.display_author(avatar) + ' ', class: 'author'
    concat_span_tag "#{t(:text_added_comment)} ", class: 'text'
    concat link_to "#{distance_of_time_in_words(comment.created_at, Time.now)} #{t(:label_ago)}. ", "#comment-#{comment.id}", class: "dark-link"
  end

  def comment_block_header_actions(comment)
    content_tag :div, class: 'right actions' do
      concat comment.edit_link
      concat comment.delete_link
    end
  end

  def comment_block_header_edited_indicator(comment)
    content_tag :span, {class: 'edited'} do
      concat "#{t(:text_edited)} on"
      concat_span_tag comment.update_date, {class: 'history-date'}
    end
  end

  # Build comment creation form.
  # @param [ActiveRecord::Base] model : model that belongs to the new comment.
  def post_comment_form(model)
    rorganize_form_for model.new_comment, html: {class: 'form', remote: true} do |f|
      concat f.hidden_field :commentable_id, value: model.new_comment.commentable_id
      concat f.hidden_field :commentable_type, value: model.new_comment.commentable_type
      concat hidden_field_tag :project_id, model.project.slug
      concat f.input :content, input_html: { rows: 12, class: 'fancyEditor', id: 'comment-form'}
      concat f.button :submit
    end
  end

  # Build comment edition form.
  # @param [Comment] model : the comment to edit.
  def put_comment_form(comment)
    rorganize_form_for comment, html: {class: 'form', remote: true, method: :put, data: {role: "comment-form"}} do |f|
      concat hidden_field_tag :project_id, comment.project.slug
      concat f.input :content, input_html: { rows: 12, class: 'fancyEditor', id: 'comment-form'}
      concat f.button :submit
      concat link_to t(:button_close), "#", class: "btn btn-default", data: {action: "close"}
    end
  end
end