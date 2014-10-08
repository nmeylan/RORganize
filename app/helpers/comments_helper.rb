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
          safe_concat comment_block_render(comment, selected_comment.id, avatar)
        else
          safe_concat comment_block_render(comment, nil, avatar)
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
    content_tag :div, {id: "comment-#{comment.id}", class: 'comment-block'}, &Proc.new {
      safe_concat comment.author_avatar unless avatar
      safe_concat content_tag :div, class: "comment-header #{'display-avatar' if comment.author_avatar?}", &Proc.new {
        safe_concat content_tag :span, comment.display_author(avatar) + ' ', class: 'author'
        safe_concat content_tag :span, t(:text_added_comment) + ' ', class: 'text'
        safe_concat "#{distance_of_time_in_words(comment.created_at, Time.now)} #{t(:label_ago)}. "
        safe_concat content_tag :span, comment.creation_date, {class: 'history-date'}
        if comment.edited?
          safe_concat content_tag(:span, {class: 'edited'}, &Proc.new {
            safe_concat "#{t(:text_edited)} on"
            safe_concat content_tag(:span, comment.update_date, {class: 'history-date'}) })
        end
        safe_concat content_tag :div, class: 'right actions', &Proc.new {
          safe_concat comment.edit_link
          safe_concat comment.delete_link
        }
      }
      safe_concat content_tag :div, class: css_class, &Proc.new {
        markdown_to_html comment.content, comment.model
      }
    }
  end

  # Build comment creation form.
  # @param [ActiveRecord::Base] model : model that belongs to the new comment.
  def post_comment_form(model)
    form_for model.new_comment, url: comments_path, html: {class: 'form', remote: true} do |f|
      safe_concat f.hidden_field :commentable_id, value: model.new_comment.commentable_id
      safe_concat f.hidden_field :commentable_type, value: model.new_comment.commentable_type
      safe_concat hidden_field_tag :project_id, model.project.slug
      comment_form_content(f)
    end
  end

  # Build comment edition form.
  # @param [Comment] model : the comment to edit.
  def put_comment_form(comment)
    form_for comment, html: {class: 'form', remote: true, method: :put} do |f|
      safe_concat hidden_field_tag :project_id, comment.project.slug
      comment_form_content(f)
    end
  end

  # Build content for the forms.
  # @param [Form] f : the form.
  def comment_form_content(f)
    safe_concat content_tag :p, &Proc.new {
      safe_concat f.label :content, &Proc.new {
        safe_concat t(:field_content)
        safe_concat content_tag :span, '*', class: 'required'
      }
      safe_concat f.text_area :content, :rows => 12, :class => 'fancyEditor', id: 'comment-form'
    }
    safe_concat submit_tag t(:button_submit)
  end
end