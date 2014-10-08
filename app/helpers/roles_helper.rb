# Author: Nicolas Meylan
# Date: 07.07.14
# Encoding: UTF-8
# File: roles_helper.rb

module RolesHelper
  # Build a list of roles.
  # @param [Array] collection of roles.
  def list(collection)
    content_tag :table, class: 'role list' do
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :td, sortable('roles.name', t(:field_name))
        safe_concat content_tag :td, nil
      }
      safe_concat(collection.collect do |role|
        content_tag :tr, {class: 'odd-even', id: %Q(role-#{role.id})} do
          safe_concat content_tag :td, role.edit_link, class: 'name'
          safe_concat content_tag :td, role.delete_link, class: 'action'
        end
      end.join.html_safe)
    end
  end
end