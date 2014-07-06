class QueriesDecorator < ApplicationCollectionDecorator
  def display_collection
    super do
      h.query_list(self)
    end
  end
end
