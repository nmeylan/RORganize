class UsersDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def new_link
    super(h.t(:link_new_user), h.new_user_path)
  end

end
