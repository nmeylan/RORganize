# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comments_helper.rb

module CommentsHelper
  def comments_block(collection)
    content_tag :div, id: 'comments_block' do
      collection.collect do |comment|
        render_single_comment(comment)
      end.join(content_tag :div, nil, class: 'separator').html_safe
    end
  end

  def render_single_comment(comment)
    safe_concat content_tag :span, class: 'header', &Proc.new {
      safe_concat content_tag :span, comment.display_author + ' ', class: 'author'
      safe_concat content_tag :span, t(:text_added_comment) + ' - ', class: 'text'
      safe_concat content_tag :span, comment.creation_date, class: 'text'
    }
    safe_concat content_tag :div, class: 'content', &Proc.new {
      textile_to_html comment.content
    }
  end
end