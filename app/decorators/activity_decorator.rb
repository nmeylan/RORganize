# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: activity_decorator.rb

module ActivityDecorator

  # Render document creation info.
  def creation_info
    h.content_tag :div, class: 'creation-info wiki-page-creation-info light-gray' do
      h.content_tag :p do
        h.content_tag :em do
          creation_info_content
        end
      end
    end
  end

  def creation_info_content
    h.concat creation_info_date
    h.concat model.author ? model.author.decorate.user_link(false) : h.t(:label_unknown)
    h.concat '.'
    h.concat update_info_date unless model.created_at.eql?(model.updated_at)
  end

  def update_info_date
    " #{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)} #{h.t(:label_ago)}."
  end

  def creation_info_date
    "#{h.t(:label_added)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} "
  end

  # @return [String] version name.
  def display_version
    display_info_square(model.version, 'milestone')
  end

  # @return [String] category name.
  def display_category
    display_info_square(model.category, 'tag')
  end

  def display_info_square(attribute, glyph, none_indicator = true)
    if attribute
      h.content_tag :span,h.glyph(attribute.caption, glyph), {class: 'info-square'}
    else
      '-' if none_indicator
    end
  end

  # @param [Project] project.
  # @return [String] link to project if not nil.
  def display_project_link(project)
    unless project
      h.content_tag :span, class: 'project', &Proc.new {
        h.concat 'at '
        h.concat project_link
      }
    end
  end

  # Render a link to add a comment. Can be used by all commentable model.
  def new_comment_link
    if User.current.allowed_to?('comment', h.controller_name, model.project)
      h.link_to h.glyph(h.t(:link_comment), 'comment'), '#add-comment', {id: 'new-comment-link', class: 'btn btn-primary'}
    end
  end

  # @return [Comment] new comment record.
  def new_comment
    Comment.new({commentable_type: model.class, commentable_id: model.id})
  end

  # @return [String] render a comment creation form.
  def add_comment_block
    if User.current.allowed_to?('comment', h.controller_name, model.project)
      h.render partial: 'comments/form', locals: {model: self}
    end
  end

  # @return [String] render how many comments belongs to the models.
  def comment_presence_indicator
    h.comment_presence(model.comments_count)
  end

end