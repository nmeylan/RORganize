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
      safe_concat image_tag comment.author_avatar.url(:thumb) unless avatar
      safe_concat content_tag :div, class: 'comment_header', &Proc.new {
        safe_concat content_tag :span, comment.display_author(avatar) + ' ', class: 'author'
        safe_concat content_tag :span, t(:text_added_comment) + ' ', class: 'text'
        safe_concat "#{distance_of_time_in_words(comment.created_at, Time.now)} #{t(:label_ago)}. "
        safe_concat content_tag :span, comment.created_at.strftime(Rorganize::TIME_FORMAT), {class: 'history_date'}
      }
      safe_concat content_tag :div, class: css_class, &Proc.new {
        textile_to_html comment.content
      }
    }
  end
end