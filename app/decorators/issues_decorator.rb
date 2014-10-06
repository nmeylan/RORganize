class IssuesDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

  def no_data_glyph_name
    'issue-opened'
  end

  def display_collection
    super(false, h.t(:text_no_issues))
  end

end
