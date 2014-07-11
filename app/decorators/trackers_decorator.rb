class TrackersDecorator < ApplicationCollectionDecorator

  def new_link
    super(h.t(:link_new_tracker), h.new_tracker_path, nil)
  end

end
