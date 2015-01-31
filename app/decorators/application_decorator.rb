class ApplicationDecorator < Draper::Decorator
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include ActivityDecorator
  include GenericDecorator

  EDIT_LINK = h.t(:link_edit)
  DELETE_LINK  = h.t(:link_delete)

  # @return [Boolean] true if the model description exists.
  def description?
    model.description && !model.description.eql?('')
  end

  # @return [String] markdown rendered description.
  def display_description
    if description?
      h.markdown_to_html(model.description, model)
    else
      content_tag :p, '-'
    end
  end

  # @return [String] formatted created_at date.
  def display_created_at
    model.created_at ? model.created_at.to_formatted_s(:short) : '-'
  end

  # @return [String] formatted updated_at date.
  def display_updated_at
    model.updated_at ? model.updated_at.to_formatted_s(:short) : '-'
  end

  # @param [String] content of the field.
  # @return [String] span containing the disabled content.
  def disabled_field(content)
    h.content_tag :span, content, {class: 'disabled-field'}
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
    options = options.merge({class: 'button'})
    link_to_with_permissions(h.glyph(label, 'pencil'), path, project, owner, options)
  end

  def show_link(path, project = nil, owner = nil, options = {})
    link_to_with_permissions(self.resized_caption, path, project, nil, options)
  end

  # Render a link to delete the model.
  # @param [String] label : link label.
  # @param [String] path to controller.
  # @param [Project] project the project that belongs to the model.
  # @param [Object] owner the owner of the model. (e.g issue.author)
  # @param [Hash] options : html_options.
  def delete_link(label, path, project = nil, owner = nil, options = {})
    default_options = {method: :delete, remote: true, confirm: h.t(:text_delete_item), class: 'delete-link button danger'}
    link_to_with_permissions(h.glyph(label, 'trashcan'), path, project, owner, default_options.merge(options))
  end

  # Render a link to increment the model position.
  # @param [String] path to the controller.
  def inc_position_link(path)
    if model.position > 1
      h.link_to(h.glyph('', 'arrow-up'), path, {class: 'icon icon-up-arrow change-position dec'})
    else
      h.link_to(h.glyph('', 'arrow-up'), '#', {class: 'icon icon-disabled-up-arrow'})
    end
  end

  # Render a link to decrement the model position.
  # @param [Numeric] size of the collection.
  # @param [String] path to the controller.
  def dec_position_link(collection_size, path)
    if model.position < collection_size
      h.link_to h.glyph('', 'arrow-down'), path, {class: 'icon icon-down-arrow change-position inc'}
    else
      h.link_to h.glyph('', 'arrow-down'), '#', {class: 'icon icon-disabled-down-arrow'}
    end
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

  def watch(project, is_a_project = false)
    if is_a_project && User.current.allowed_to?('watch', 'projects', project) || User.current.allowed_to?('watch', h.controller_name, project)
      h.toggle_watcher_link(model, project, false)
    end
  end

  def unwatch(project, is_a_project = false)
    if is_a_project && User.current.allowed_to?('watch', 'projects', project) ||User.current.allowed_to?('watch', h.controller_name, project)
      h.toggle_watcher_link(model, project, true)
    end
  end

  # Render a link to delete an attachment.
  # @param [String] path : to controller to perform the action.
  # @param [Project] project : project belongs to the attachment.
  def delete_attachment_link(path, project)
    link_to_with_permissions h.glyph(h.t(:link_delete), 'trashcan'), path, project, nil, {remote: true, confirm: h.t(:text_delete_item), method: :delete, class: 'button danger'}
  end

  # Render a link to download an attachment.
  # @param [Attachment] attachment : the attachment.
  # @param [String] path : to controller.
  def download_attachment_link(attachment, path = nil)
    path ||= h.url_for({controller: h.controller_name, action: 'download_attachment', id: attachment.id})
    h.link_to h.glyph(attachment.file_file_name, attachment.icon_type), path
  end

  # @return [String] an indicator if model has attachments.
  def attachment_presence_indicator
    h.content_tag :span, nil, {class: "octicon octicon-attachment #{model.attachments.empty? ? 'smooth-gray' : ''}"}
  end

  # @param [Numeric] length : number or characters.
  def resized_caption(length = 50)
    h.resize_text(model.caption, length)
  end


end