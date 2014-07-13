class TrackerDecorator < ApplicationDecorator
  delegate_all

  def edit_link
    link = link_to_with_permissions(model.caption, h.edit_tracker_path(model.id), nil, nil)
    link ? link : disabled_field(model.caption)
  end

  def delete_link
    link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'), h.tracker_path(tracker.id), nil, {:method => :delete,:remote => true,:confirm => h.t(:text_delete_item)})
  end
end
