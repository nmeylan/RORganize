class RolesDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_role), h.new_role_path)
  end
end
