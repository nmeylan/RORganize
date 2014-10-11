module ProjectsHelper
  include JournalsHelper

  # Build a list of members group by their role in project.
  # @param [Hash] members_hash  with following structure {role: members}.
  def members_list(members_hash)
    content_tag :div do
      members_hash.collect do |role, members|
        members_list_block(members, role)
      end.join.html_safe
    end
  end

  def members_list_block(members, role)
    content_tag :div, class: 'members-block' do
      safe_concat content_tag :h4, "#{role}", {class: 'badge badge-role'}
      safe_concat member_list_row(members)
    end
  end

  def member_list_row(members)
    content_tag :span, members.collect { |member| member.user.decorate.user_link(true) }.join(', ').html_safe, class: 'members-grouped-by-role'
  end

  # Build a list of projects.
  # @param [Array] projects.
  # @param [boolean] allow_to_star : if true user can star projects from the list, else the star button is hidden.
  def project_list(projects, allow_to_star)
    content_tag :ul, class: "fancy-list project-list #{allow_to_star ? 'sortable' : '' }" do
      projects.collect do |project|
        project_list_row(allow_to_star, project)
      end.join.html_safe
    end
  end

  def project_list_row(allow_to_star, project)
    content_tag :li, class: "fancy-list-item project #{project.is_archived ? 'archived' : ''}", id: project.slug do
      safe_concat project_stats(project).html_safe
      safe_concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
      safe_concat project_last_activity_info(project)
      safe_concat project_list_star_button(project) if allow_to_star && current_user
    end
  end

  def project_last_activity_info(project)
    content_tag :p, class: 'bottom-list-content project-last-activity' do
      project.last_activity_info
    end
  end

  # Build a render for project stats.
  # @param [Project] project.
  def project_stats(project)
    content_tag :ul, class: 'right-content-list project-stats' do
      safe_concat content_tag :li, (content_tag :span, nil, {class: 'octicon octicon-broadcast'}), {class: 'tooltipped tooltipped-s', label: t(:text_public_project)} if project.is_public
      safe_concat content_tag :li, (content_tag :span, project.members_count, class: 'octicon octicon-organization')
      safe_concat content_tag :li, (content_tag :span, project.issues_count, class: 'octicon octicon-issue-opened')
      safe_concat content_tag :li, (content_tag :span, nil, class: 'octicon octicon-lock') if project.is_archived
    end
  end

  # Build a render for the star project' button.
  # @param [Project] project.
  def project_list_star_button(project)
    content_tag :div, class: 'star-project' do
      safe_concat project.display_watch_button
      render_project_star_button(project)
    end
  end

  def render_project_star_button(project)
    if project.starred?
      safe_concat star_project_link(project)
    else
      safe_concat unstar_project_link(project)
    end
  end

  def unstar_project_link(project)
    star_unstar_project_link(project, t(:link_star), t(:text_star), 'icon-fav-off')
  end

  def star_project_link(project)
    star_unstar_project_link(project, t(:link_unstar), t(:text_unstar), 'icon-fav')
  end

  def star_unstar_project_link(project, label, text, icon)
    link_to(glyph(label, 'star'),
            star_project_profile_path(project.slug),
            {class: "icon #{icon} starred star tooltipped tooltipped-s star-button button",
             method: :post, remote: true, label: text})
  end


end