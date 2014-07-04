class IssuesDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

end
