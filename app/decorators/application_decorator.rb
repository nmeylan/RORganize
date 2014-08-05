class ApplicationDecorator < Draper::Decorator
  include Rorganize::PermissionManager::PermissionHandler

  def description?
    model.description && !model.description.eql?('')
  end

  def display_description
    if description?
      h.markdown_to_html(model.description)
    else
      '-'
    end
  end

  def created_at
    model.created_at ? model.created_at.to_formatted_s(:short) : '-'
  end

  def updated_at
    model.updated_at ? model.updated_at.to_formatted_s(:short) : '-'
  end

  def disabled_field(content)
    h.content_tag :span, content, {class: 'disabled_field'}
  end

  def display_history(history)
    if history && history.content.to_a.any?
      h.content_tag :div, id: 'history' do
        h.history_render(history)
      end
    end
  end

  def edit_link(label, path, project = nil, owner = nil, options = {})
    link_to_with_permissions(h.glyph(label, 'pencil'), path, project, owner, options)
  end

  def new_link(label, path, project = nil)
    link_to_with_permissions(h.glyph(label, 'plus'), path, project, nil)
  end

  def delete_link(label, path, project = nil, owner = nil, options = {})
    default_options = {:method => :delete, :remote => true, :confirm => h.t(:text_delete_item)}
    link_to_with_permissions(h.glyph(label, 'trashcan'), path, project, owner, default_options.merge(options))
  end


  def inc_position_link(path)
    if model.position > 1
      h.link_to(h.glyph('', 'arrow-up'), path, {:class => 'icon icon-up_arrow change_position dec'})
    else
      h.link_to(h.glyph('', 'arrow-up', 'disabled'), '#', {:class => 'icon icon-disabled_up_arrow'})
    end
  end

  def dec_position_link(collection_size, path)
    if model.position < collection_size
      h.link_to h.glyph('', 'arrow-down'), path, {:class => 'icon icon-down_arrow change_position inc'}
    else
      h.link_to h.glyph('', 'arrow-down', 'disabled'), '#', {:class => 'icon icon-disabled_down_arrow'}
    end
  end

  #Commentable model
  def new_comment_link
    if User.current.allowed_to?('comment', h.controller_name, model.project)
      h.link_to h.glyph(h.t(:link_comment), 'comment'), '#add_comment', {id: 'new_comment_link'}
    end
  end
  def new_comment
    Comment.new({commentable_type: model.class, commentable_id: model.id})
  end

  def add_comment_block
    if User.current.allowed_to?('comment', h.controller_name, model.project)
      h.render partial: 'comments/form', locals: {model: self}
    end
  end

  #Attachable model
  def delete_attachment_link(path, project)
    link_to_with_permissions h.glyph(h.t(:link_delete), 'trashcan'), path, project, nil, {:remote => true, :confirm => h.t(:text_delete_item), :method => :delete}
  end

  def download_attachment_link(attachment, path = nil)
    path ||= h.url_for({controller: h.controller_name, action: 'download_attachment', id: attachment.id})
    h.link_to h.glyph(attachment.file_file_name, attachment.icon_type), path
  end

end