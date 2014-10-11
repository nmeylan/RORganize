class CommentDecorator < ApplicationDecorator
  delegate_all
  decorates_association :author

  # @return [String] formatted creation date.
  def creation_date
    model.created_at.strftime(Rorganize::TIME_FORMAT)
  end

  # @return [String] formatted update date.
  def update_date
    model.updated_at.strftime(Rorganize::TIME_FORMAT)
  end

  # @return [String] formatted creation date.
  def display_creation_at
    model.created_at.strftime('%I:%M%p')
  end

  # Render the link to user.
  # @param [Boolean] avatar : if true display the user's avatar else don't display it.
  def display_author(avatar = true)
    model.author = model.author.decorate unless model.author.decorated?
    model.author ? model.author.user_link(avatar) : h.t(:label_unknown)
  end

  # @return [String] link to model project.
  def project_link
    h.fast_project_link(model.project)
  end

  # @return [String] user avatar image.
  def author_avatar
    author_avatar? ? h.image_tag(model.author.avatar.avatar.url(:thumb), {class: 'avatar'}) : ''
  end

  # @return [Boolean] true if user has an avatar.
  def author_avatar?
    model.author && model.author.avatar
  end

  # see #ApplicationDecorator::edit_link
  def edit_link
    if user_allowed_to_edit?
      h.link_to h.glyph(h.t(:link_edit), 'pencil'), h.edit_comment_path(model.id), {class: 'edit-comment button', remote: true}
    end
  end

  def user_allowed_to_edit?
    User.current.allowed_to?('edit_comment_not_owner', 'comments', model.project) || model.author?(User.current)
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    if User.current.allowed_to?('destroy_comment_not_owner', 'comments', model.project) || model.author?(User.current)
      h.link_to h.glyph(h.t(:link_delete), 'trashcan'), h.comment_path(model.id), {class: 'button danger', method: :delete, remote: true, 'data-confirm' => h.t(:text_delete_item)}
    end
  end

  # Render a remote link to comment.
  def remote_show_link
    h.link_to h.t(:link_comment), h.comment_path(model.id), {class: 'view-comment', id: model.id, remote: true}
  end

  # Render the type of the commented object.
  def display_object_type
    type = self.commentable_type
    if is_a_issue?(type)
      display_issue_type
    elsif type.eql?('Document')
      h.fast_document_link(self.document, self.project).html_safe
    else
      h.content_tag :b, "#{type.downcase} #{self.journalizable_identifier}"
    end
  end

  def display_issue_type
    h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase}  ##{self.issue.id} "
    h.link_to self.issue.caption, h.issue_path(self.project.slug, self.commentable_id)
  end

  def is_a_issue?(type)
    type.eql?('Issue') && self.issue
  end

  # Render comment details.
  def render_details
    h.content_tag :span, class: 'comment' do
      h.concat_span_tag nil, class: 'octicon octicon-comment activity-icon'
      h.concat_span_tag self.display_author, class: 'author'
      h.concat_span_tag "#{h.t(:text_added_a).capitalize} "
      h.concat_span_tag self.remote_show_link
    end
  end

  # Render comment header.
  def render_header
    h.concat_span_tag "#{h.t(:text_added_a)} "
    h.concat_span_tag self.remote_show_link
    h.concat_span_tag " #{h.t(:text_to)} "
    h.content_tag :span, self.display_object_type, class: 'object-type'
  end

end
