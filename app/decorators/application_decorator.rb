class ApplicationDecorator < Draper::Decorator
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Rorganize::PermissionManager::PermissionHandler

  # @return [Boolean] true if the model description exists.
  def description?
    model.description && !model.description.eql?('')
  end

  # @return [String] markdown rendered description.
  def display_description
    if description?
      h.markdown_to_html(model.description, model)
    else
      '-'
    end
  end

  # @return [String] formatted created_at date.
  def created_at
    model.created_at ? model.created_at.to_formatted_s(:short) : '-'
  end

  # @return [String] formatted updated_at date.
  def updated_at
    model.updated_at ? model.updated_at.to_formatted_s(:short) : '-'
  end

  # @param [String] content of the field.
  # @return [String] span containing the disabled content.
  def disabled_field(content)
    h.content_tag :span, content, {class: 'disabled_field'}
  end

  # @param [History] history.
  # @return [String] the rendered history block.
  def display_history(history)
    h.content_tag :div, id: 'history' do
      if history && history.content.to_a.any?
        h.history_render(history)
      end
    end
  end

  # Render a link to edit the model.
  # @param [String] label : link label.
  # @param [String] path to controller.
  # @param [Project] project the project that belongs to the model.
  # @param [Object] owner the owner of the model. (e.g issue.author)
  # @param [Hash] options : html_options.
  def edit_link(label, path, project = nil, owner = nil, options = {})
    link_to_with_permissions(h.glyph(label, 'pencil'), path, project, owner, options)
  end

  # Render a link to create the model.
  # @param [String] label : link label.
  # @param [String] path to controller.
  # @param [Project] project the project that belongs to the model.
  def new_link(label, path, project = nil)
    link_to_with_permissions(h.glyph(label, 'plus'), path, project, nil)
  end

  # Render a link to delete the model.
  # @param [String] label : link label.
  # @param [String] path to controller.
  # @param [Project] project the project that belongs to the model.
  # @param [Object] owner the owner of the model. (e.g issue.author)
  # @param [Hash] options : html_options.
  def delete_link(label, path, project = nil, owner = nil, options = {})
    default_options = {:method => :delete, :remote => true, :confirm => h.t(:text_delete_item), class: 'delete_link'}
    link_to_with_permissions(h.glyph(label, 'trashcan'), path, project, owner, default_options.merge(options))
  end

  # Render a link to increment the model position.
  # @param [String] path to the controller.
  def inc_position_link(path)
    if model.position > 1
      h.link_to(h.glyph('', 'arrow-up'), path, {:class => 'icon icon-up_arrow change_position dec'})
    else
      h.link_to(h.glyph('', 'arrow-up', 'disabled'), '#', {:class => 'icon icon-disabled_up_arrow'})
    end
  end

  # Render a link to decrement the model position.
  # @param [Numeric] size of the collection.
  # @param [String] path to the controller.
  def dec_position_link(collection_size, path)
    if model.position < collection_size
      h.link_to h.glyph('', 'arrow-down'), path, {:class => 'icon icon-down_arrow change_position inc'}
    else
      h.link_to h.glyph('', 'arrow-down', 'disabled'), '#', {:class => 'icon icon-disabled_down_arrow'}
    end
  end

  # Render a link to add a comment. Can be used by all commentable model.
  def new_comment_link
    if User.current.allowed_to?('comment', h.controller_name, model.project)
      h.link_to h.glyph(h.t(:link_comment), 'comment'), '#add_comment', {id: 'new_comment_link'}
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

  def display_watch_button
    is_a_project = model.is_a?(Project)
    project = is_a_project ? model : model.project
    if  model.watch_by?(User.current)
      unwatch(project, is_a_project)
    else
      watch(project, is_a_project)
    end
  end

  def watch(project, no_permission_required = false)
    if no_permission_required || User.current.allowed_to?('watch', h.controller_name, project)
      h.watch_link(model, project)
    end
  end

  def unwatch(project, no_permission_required = false)
    if no_permission_required || User.current.allowed_to?('watch', h.controller_name, project)
      h.unwatch_link(model, model.watcher_for(User.current), project)
    end
  end

  # Render a link to delete an attachment.
  # @param [String] path : to controller to perform the action.
  # @param [Project] project : project belongs to the attachment.
  def delete_attachment_link(path, project)
    link_to_with_permissions h.glyph(h.t(:link_delete), 'trashcan'), path, project, nil, {:remote => true, :confirm => h.t(:text_delete_item), :method => :delete}
  end

  # Render a link to download an attachment.
  # @param [Attachment] attachment : the attachment.
  # @param [String] path : to controller.
  def download_attachment_link(attachment, path = nil)
    path ||= h.url_for({controller: h.controller_name, action: 'download_attachment', id: attachment.id})
    h.link_to h.glyph(attachment.file_file_name, attachment.icon_type), path
  end

  # @param [Numeric] length : number or characters.
  def resized_caption(length = 50)
    resize_text(model.caption, length)
  end

  # @param [String] text : text to resize.
  # @param [Numeric] length : number of characters.
  def resize_text(text, length = 50)
    text.length > length ? "#{text[0..length]}..." : text
  end

end