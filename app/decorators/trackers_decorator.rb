class TrackersDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_tracker), h.new_tracker_path, nil)
  end

  # see #TrackersHelper::project_tracker_list
  def settings_list
    h.project_tracker_list(self, context[:checked_ids])
  end
end
