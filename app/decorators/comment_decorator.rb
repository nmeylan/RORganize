class CommentDecorator < ApplicationDecorator
  decorates_association :author, with: :user
  delegate_all

  def creation_date
    model.created_at.strftime(Rorganize::TIME_FORMAT)
  end

  def display_creation_at
    model.created_at.strftime("%I:%M%p")
  end

  def display_author
    model.author ? model.author.decorate.user_link : h.t(:label_unknown)
  end

  def edit_link

  end

  def delete_link

  end

  def remote_show_link
    h.link_to h.t(:link_comment), h.comment_path(model.id), {class: 'view_comment', id: model.id, remote: true}
  end

  def display_object_type
    type = self.commentable_type
    if type.eql?('Issue')
      h.safe_concat h.content_tag :b, "#{self.issue.tracker.caption.downcase} "
      h.link_to self.issue.caption, h.issue_path(self.project.slug, self.commentable_id)
    end
  end

  def render_details
    h.content_tag :span, class: 'comment' do
      h.safe_concat h.content_tag :span, nil, class: "octicon octicon-comment"
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
