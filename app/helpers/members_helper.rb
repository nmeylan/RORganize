# Author: Nicolas Meylan
# Date: 5 mars 2013
# Encoding: UTF-8
# File: member_helper.rb

module MembersHelper
  # Build a list of members.
  # @param [Array] collection of members.
  def list(collection, roles)
    content_tag :table, {class: 'member list'}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, sortable('users.name', 'Name'), {class: 'list-left'}
        safe_concat content_tag :th, sortable('roles.name', 'Role')
        safe_concat content_tag :th, nil
      }
      safe_concat(collection.collect do |member|
        content_tag :tr, {class: 'odd-even', id: member.id} do
          safe_concat content_tag :td, member.caption, {class: 'list-left name'}
          safe_concat content_tag :td, member.role_selection(roles), {class: 'list-center role'}
          safe_concat content_tag :td, member.delete_link, {class: 'action'}
        end
      end.join.html_safe)
    }
  end

end
