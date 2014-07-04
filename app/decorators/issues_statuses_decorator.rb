class IssuesStatusesDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def new_link
    super(h.t(:link_new_status), h.new_issues_status_path)
  end
end
