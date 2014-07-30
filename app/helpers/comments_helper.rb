# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_helper.rb

module CommentsHelper
  def comments_block(collection, selected_comment = nil)
    content_tag :div, id: 'comments_block' do
      collection.collect do |comment|
        if selected_comment
          render_single_comment(comment, selected_comment.id)
        else
          render_single_comment(comment)
        end
      end.join.html_safe
    end
  end

  def render_single_comment(comment, selected_comment_id = nil)
    css_class = comment.id.eql?(selected_comment_id) ? 'comment selected' : 'comment'
    safe_concat content_tag :div, {id: "comment_#{comment.id}", class: css_class}, &Proc.new {
      safe_concat content_tag :h3, class: 'header', &Proc.new {
        safe_concat content_tag :span, comment.display_author + ' ', class: 'author'
        safe_concat content_tag :span, t(:text_added_comment) + '. ', class: 'text'
        safe_concat content_tag :span, comment.creation_date, class: 'history_date'
      }
      safe_concat content_tag :div, class: 'content', &Proc.new {
        textile_to_html comment.content
      }
    }
  end
end