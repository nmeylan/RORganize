class MembersDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::display_collection
  def display_collection
    super(false, nil, true) do
      h.list(self, context[:roles])
    end
  end

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_add_member), h.new_project_member_path(context[:project]), context[:project], {method: :get, remote: true, id: 'add-members', data: {toggle: "dynamic-modal"}})
  end
end
