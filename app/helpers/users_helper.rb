# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_helper.rb

module UsersHelper
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

  def projects(user)
    content_tag :ul do
      user.members.collect do |member|
        content_tag :li do
          safe_concat link_to member.project.caption.capitalize, overview_projects_path(member.project.slug)
          safe_concat " (#{member.role.caption}, #{link_to member.assigned_issues.size, issues_path(member.project.slug, {type: :filter, filter_list: :assigned_to, filter: {assigned_to: {operator: :equal, value: [user.id]}}}) } #{t(:text_assigned_issues)})"
        end
      end.join.html_safe
    end
  end
end
