# Author: Nicolas Meylan
# Date: 29 sept. 2012
# Encoding: UTF-8
# File: users_helper.rb

module UsersHelper
  # Build a list of users.
  # @param [Array] collection of users.
  def list(collection)
    content_tag :table, {class: 'user list'}, &Proc.new {
      safe_concat list_header
      safe_concat list_body(collection)
    }
  end

  def list_header
    content_tag :tr, class: 'header' do
      list_th sortable('users.id', '#')
      list_th sortable('users.login', 'Login')
      list_th sortable('users.name', 'Name')
      list_th sortable('users.email', 'Email')
      list_th sortable('users.admin', 'Administrator')
      list_th sortable('users.last_sign_in_at', 'Last sign in')
    end
  end

  def list_body(collection)
    collection.collect do |user|
      list_row(user)
    end.join.html_safe
  end

  def list_row(user)
    content_tag :tr, class: 'odd-even user-tr' do
      list_td user.id, class: 'list-center id'
      list_td user.login, class: 'list-center login'
      list_td user.show_link, class: 'list-center name'
      list_td user.email, class: 'list-center email'
      list_td user.display_is_admin, class: 'list-center admin'
      list_td user.sign_in, class: 'list-center last-sign-in'
    end
  end

  # Build a list of projects in which the given user is member.
  # @param [User] user.
  def projects(user)
    content_tag :ul, {class: 'profile profile-user-projects'} do
      user.members.collect do |member|
        projects_list_row(member, user)
      end.join.html_safe
    end
  end

  def projects_list_row(member, user)
    content_tag :li do
      safe_concat link_to member.project.caption.capitalize, overview_projects_path(member.project.slug)
      safe_concat assigned_to_user_issues(member, user)
      safe_concat content_tag :span, member.role.caption, {class: 'badge'}
    end
  end

  # Build a filter link to opened issues assigned to "user".
  # @param [Member] member
  # @param [User] user
  def assigned_to_user_issues(member, user)
    " (#{link_to member.assigned_issues.to_a.count { |issue| issue.open? }, assigned_to_user_filter_path(member, user) } #{t(:text_assigned_issues)}) "
  end

  # Build a filter link path to opened issues assigned to "user".
  # @param [Member] member
  # @param [User] user
  def assigned_to_user_filter_path(member, user)
    issues_path(member.project.slug, {type: :filter,
                                      filters_list: [:assigned_to, :status],
                                      filter: {assigned_to: {operator: :equal, value: [user.id]}, status: {operator: :open}}})
  end
end
