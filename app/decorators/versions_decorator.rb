class VersionsDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_version), h.new_version_path(context[:project].slug), context[:project])
  end

end
