class QueriesDecorator < ApplicationCollectionDecorator
  def display_collection
    super do
      h.query_list(self)
    end
  end

  def pagination_path
    context[:queries_url]
  end

  def sortable_action
    context[:action_name]
  end
end
