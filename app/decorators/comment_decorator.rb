class CommentDecorator < ApplicationDecorator
  decorates_association :author, with: :user
  delegate_all

  def creation_date
    model.created_at.strftime(Rorganize::TIME_FORMAT)
  end

  def author
    model.author ? model.author.decorate.user_link : h.t(:label_unknown)
  end

  def edit_link

  end

  def delete_link

  end

end
