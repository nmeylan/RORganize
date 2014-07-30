class CommentsDecorator < ApplicationCollectionDecorator

  def display_collection()
    super do
      h.comments_block(self, context[:selected_comment], false)
    end
  end


end
