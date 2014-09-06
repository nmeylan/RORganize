class IssuesDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_issue), h.new_issue_path(context[:project].slug), context[:project])
  end

  def display_simple_list
    if object.to_a.any?
      h.simple_list(self)
    else
      h.content_tag :div, h.t(:text_no_data), class: 'no-data'
    end
  end

end
