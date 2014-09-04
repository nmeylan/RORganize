class CommentDecorator < ApplicationDecorator
  delegate_all
  decorates_association :author

  def creation_date
    model.created_at.strftime(Rorganize::TIME_FORMAT)
  end

  def update_date
    model.updated_at.strftime(Rorganize::TIME_FORMAT)
  end

  def display_creation_at
    model.created_at.strftime("%I:%M%p")
  end

  def display_author(avatar = true)
    model.author = model.author.decorate unless model.author.decorated?
    model.author ? model.author.user_link(avatar) : h.t(:label_unknown)
  end

  def project_link
    h.fast_project_link(model.project)
  end

  def display_project_link(project)
    unless project
      h.safe_concat h.content_tag :span, class: 'object_type', &Proc.new{
        h.safe_concat 'on '
        h.safe_concat project_link
      }
    end
  end

  def author_avatar
    author_avatar? ? h.image_tag(model.author.avatar.avatar.url(:thumb), {class: 'avatar'}) : ''
  end

  def author_avatar?
    model.author && model.author.avatar
  end

  def edit_link
    if User.current.allowed_to?('edit_comment_not_owner', 'comments', model.project) || model.author?(User.current)
      h.link_to h.glyph(h.t(:link_edit), 'pencil'), h.edit_comment_path(model.id), {class: 'edit_comment', remote: true}
    end
  end

  def delete_link
    if User.current.allowed_to?('destroy_comment_not_owner', 'comments', model.project) || model.author?(User.current)
      h.link_to h.glyph(h.t(:link_delete), 'trashcan'), h.comment_path(model.id), {:method => :delete, :remote => true, 'data-confirm' => h.t(:text_delete_item)}
    end
  end

  def remote_show_link
    h.link_to h.t(:link_comment), h.comment_path(model.id), {class: 'view_comment', id: model.id, remote: true}
  end

  def display_object_type
    type = self.commentable_type
    if type.eql?('Issue')
      h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase}  ##{self.issue.id} "
      h.link_to self.issue.caption, h.issue_path(self.project.slug, self.commentable_id)
    end
  end

  def render_details
    h.content_tag :span, class: 'comment' do
      h.safe_concat h.content_tag :span, nil, class: "octicon octicon-comment activity_icon"
      h.safe_concat h.content_tag :span, self.display_author, class: 'author'
      h.safe_concat h.content_tag :span, h.t(:text_added_a).capitalize + ' '
      h.safe_concat h.content_tag :span, self.remote_show_link
    end
  end

  def render_header
    h.safe_concat h.content_tag :span, h.t(:text_added_a) + ' '
    h.safe_concat h.content_tag :span, self.remote_show_link + ' '
    h.safe_concat h.content_tag :span, h.t(:text_to) + ' '
    h.content_tag :span, self.display_object_type
  end

  def created_at
    model.created_at
  end

end
