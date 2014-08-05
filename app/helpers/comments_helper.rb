# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_helper.rb

module CommentsHelper
  def comments_block(collection, selected_comment = nil, avatar = true)
    content_tag :div, id: 'comments_block' do
      collection.collect do |comment|
        if selected_comment
          comment_block_render(comment, selected_comment.id, avatar)
        else
          comment_block_render(comment, nil, avatar)
        end
      end.join.html_safe
    end
  end

  def comment_block_render(comment, selected_comment_id = nil, avatar = true)
    css_class = comment.id.eql?(selected_comment_id) ? 'comment_content selected' : 'comment_content'
    safe_concat content_tag :div, {id: "comment_#{comment.id}", class: 'comment_block'}, &Proc.new {
      safe_concat comment.author_avatar unless avatar
      safe_concat content_tag :div, class: "comment_header #{'display_avatar' if comment.author_avatar?}", &Proc.new {
        safe_concat content_tag :span, comment.display_author(avatar) + ' ', class: 'author'
        safe_concat content_tag :span, t(:text_added_comment) + ' ', class: 'text'
        safe_concat "#{distance_of_time_in_words(comment.created_at, Time.now)} #{t(:label_ago)}. "
        safe_concat content_tag :span, comment.creation_date, {class: 'history_date'}
        if comment.edited?
          safe_concat content_tag(:span, {class: 'edited'}, &Proc.new {
            safe_concat "#{t(:text_edited)} on"
            safe_concat content_tag(:span, comment.update_date, {class: 'history_date'}) })
        end
        safe_concat content_tag :div, class: 'right actions', &Proc.new {
          safe_concat comment.edit_link
          safe_concat comment.delete_link
        }
      }
      safe_concat content_tag :div, class: css_class, &Proc.new {
        textile_to_html comment.content
      }
    }
  end

  def post_comment_form(model)
    form_for model.new_comment, url: comments_path, html: {class: 'form', remote: true} do |f|
      safe_concat f.hidden_field :commentable_id, value: model.new_comment.commentable_id
      safe_concat f.hidden_field :commentable_type, value: model.new_comment.commentable_type
      safe_concat f.hidden_field :project_id, value: model.project.id
      comment_form_content(f)
    end
  end

  def put_comment_form(comment)
    form_for comment, html: {class: 'form', remote: true, method: :put} do |f|
      comment_form_content(f)
    end
  end

  def comment_form_content(f)
    safe_concat content_tag :p, &Proc.new {
      safe_concat f.label :content, &Proc.new {
        safe_concat t(:field_content)
        safe_concat content_tag :span, '*', class: 'required'
      }
      safe_concat f.text_area :content, :rows => 12, :class => 'fancyEditor'
    }
    safe_concat submit_tag t(:button_submit)
  end
end