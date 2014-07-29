class CommentsDecorator < ApplicationCollectionDecorator

  def display_collection
    super do
      h.comments_block(self)
    end
  end


end
