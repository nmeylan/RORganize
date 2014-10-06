class VersionsDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_version), h.new_version_path(context[:project].slug), context[:project])
  end

  def no_data_glyph_name
    'milestone'
  end

  def display_collection
    super(false, h.t(:text_no_versions))
  end

end
