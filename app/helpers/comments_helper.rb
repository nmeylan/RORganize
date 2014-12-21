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
    content_tag :div, {id: "comment-#{comment.id}", class: 'comment-block'} do
      concat comment.author_avatar unless avatar
      concat comment_block_header(avatar, comment)
      concat comment_block_content(comment, css_class)
    end
  end

  def comment_block_content(comment, css_class)
    content_tag :div, class: css_class do
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
    concat "#{distance_of_time_in_words(comment.created_at, Time.now)} #{t(:label_ago)}. "
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
    form_for model.new_comment, url: comments_path, html: {class: 'form', remote: true} do |f|
      concat f.hidden_field :commentable_id, value: model.new_comment.commentable_id
      concat f.hidden_field :commentable_type, value: model.new_comment.commentable_type
      concat hidden_field_tag :project_id, model.project.slug
      comment_form_content(f)
    end
  end

  # Build comment edition form.
  # @param [Comment] model : the comment to edit.
  def put_comment_form(comment)
    form_for comment, html: {class: 'form', remote: true, method: :put} do |f|
      concat hidden_field_tag :project_id, comment.project.slug
      comment_form_content(f)
    end
  end

  # Build content for the forms.
  # @param [Form] f : the form.
  def comment_form_content(f)
    concat content_tag :p, &Proc.new {
      concat comment_form_label(f)
      concat f.text_area :content, rows: 12, class: 'fancyEditor', id: 'comment-form'
    }
    concat submit_tag t(:button_submit)
  end

  def comment_form_label(f)
    f.label :content do
      concat t(:field_content)
      concat content_tag :span, '*', class: 'required'
    end
  end
end