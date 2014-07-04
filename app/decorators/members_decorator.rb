class MembersDecorator < ApplicationCollectionDecorator

 def display_collection
   super do
     h.list(self, context[:roles])
   end
 end

  def new_link
    super(h.t(:link_add_member), h.new_member_path(context[:project]), context[:project], {:method => :get, :remote => true, :id => 'add_members'})
  end
end
