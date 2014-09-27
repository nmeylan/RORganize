# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_helper.rb

module UsersHelper
  # Build a list of users.
  # @param [Array] collection of users.
  def list(collection)
    content_tag :table, {class: 'user list'}, &Proc.new {
      safe_concat content_tag :tr, class: 'header', &Proc.new {
        safe_concat content_tag :th, sortable('users.id', '#')
        safe_concat content_tag :th, sortable('users.login', 'Login')
        safe_concat content_tag :th, sortable('users.name', 'Name')
        safe_concat content_tag :th, sortable('users.email', 'Email')
        safe_concat content_tag :th, sortable('users.admin', 'Administrator')
        safe_concat content_tag :th, sortable('users.last_sign_in_at', 'Last sign in')
      }
      safe_concat(collection.collect do |user|
        content_tag :tr, class: 'odd_even user_tr' do
          safe_concat content_tag :td, user.id, class: 'list_center id'
          safe_concat content_tag :td, user.login, class: 'list_center login'
          safe_concat content_tag :td, user.show_link, class: 'list_center name'
          safe_concat content_tag :td, user.email, class: 'list_center email'
          safe_concat content_tag :td, user.display_is_admin, class: 'list_center admin'
          safe_concat content_tag :td, user.sign_in, class: 'list_center last_sign_in'
        end
      end.join.html_safe)
    }
  end

  # Build a list of projects in which the given user is member.
  # @param [User] user.
  def projects(user)
    content_tag :ul, {class: 'profile profile_user_projects'} do
      user.members.collect do |member|
        content_tag :li do
          safe_concat link_to member.project.caption.capitalize, overview_projects_path(member.project.slug)
          safe_concat " (#{link_to member.assigned_issues.to_a.count { |issue| issue.open? }, issues_path(member.project.slug, {type: :filter, filters_list: [:assigned_to, :status], filter: {assigned_to: {operator: :equal, value: [user.id]}, status: {operator: :open}}}) } #{t(:text_assigned_issues)}) "
          safe_concat content_tag :span, member.role.caption, {class: 'badge'}
        end
      end.join.html_safe
    end
  end
end
