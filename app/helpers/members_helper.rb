# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF-8
# File: member_helper.rb

module MembersHelper
  # Build a list of members.
  # @param [Array] collection of members.
  def list(collection, roles)
    content_tag :table, {class: 'member list'}, &Proc.new {
      concat list_header
      concat list_body(collection, roles)
    }
  end

  def list_body(collection, roles)
    collection.collect do |member|
      list_row(member, roles)
    end.join.html_safe
  end

  def list_row(member, roles)
    content_tag :tr, {class: 'odd-even', id: member.id} do
      list_td member.caption, {class: 'list-left name'}
      list_td member.role_selection(roles), {class: 'list-center role'}
      list_td member.delete_link, {class: 'action'}
    end
  end

  def list_header
    content_tag :tr, class: 'header' do
      list_th sortable('users.name', 'Name'), {class: 'list-left'}
      list_th sortable('roles.name', 'Role')
      list_th nil
    end
  end

end
