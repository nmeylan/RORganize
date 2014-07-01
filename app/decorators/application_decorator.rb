class ApplicationDecorator < Draper::Decorator
  include Rorganize::PermissionManager::PermissionHandler


  def display_description
    h.textile_to_html(yield)
  end

  def disabled_field(content)
    h.content_tag :span, content, {class: 'disabled_field'}
  end

  def edit_link(label, path, project = nil, owner = nil, options = {})
    link_to_with_permissions(h.glyph(label, 'pencil'), path ,project, owner, options)
  end

  def new_link(label, path, project = nil)
    link_to_with_permissions(h.glyph(label, 'plus'), path ,project, nil)
  end

  def delete_link(label, path, project = nil, owner = nil, options = {})
    default_options = {:method => :delete, :remote => true, :confirm => h.t(:text_delete_item)}
    link_to_with_permissions(h.glyph(label, 'trashcan'), path ,project, owner, default_options.merge(options))
  end

end