class VersionsDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_version), h.new_version_path(context[:project].slug), context[:project])
  end

end
