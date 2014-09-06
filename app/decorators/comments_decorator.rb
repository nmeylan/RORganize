class CommentsDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::display_collection
  def display_collection
    h.comments_block(self, context[:selected_comment], false)
  end


end
