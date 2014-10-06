class NotificationsDecorator < ApplicationCollectionDecorator
  delegate :current_page, :per_page, :offset, :total_entries, :total_pages

  def display_filter
    h.sidebar(context[:filters], context[:projects])
  end

  def no_data_glyph_name
    'inbox'
  end

end
