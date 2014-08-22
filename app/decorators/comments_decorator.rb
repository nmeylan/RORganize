class CommentsDecorator < ApplicationCollectionDecorator

  def display_collection()
    h.comments_block(self, context[:selected_comment], false)
  end


end
