class TrackersDecorator < ApplicationCollectionDecorator

  def new_link
    super(h.t(:link_new_tracker), h.new_tracker_path, nil)
  end

  def settings_list
    h.project_tracker_list(self, context[:checked_ids])
  end
end
