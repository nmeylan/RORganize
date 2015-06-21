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
      concat content_tag :h4, "#{role}", {class: 'badge badge-role'}
      concat member_list_row(members)
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
      concat project_stats(project).html_safe
      concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
      concat project_last_activity_info(project)
      concat project_list_star_button(project) if allow_to_star && current_user
    end
  end

  def project_last_activity_info(project)
    content_tag :p, class: 'bottom-list-content project-last-activity' do
      project.latest_activity_info
    end
  end

  # Build a render for project stats.
  # @param [Project] project.
  def project_stats(project)
    content_tag :ul, class: 'right-content-list project-stats' do
      concat content_tag :li, (content_tag :span, nil, {class: 'octicon octicon-broadcast'}),
                         {data: {title: t(:text_public_project), toggle: "tooltip"}} if project.is_public
      concat member_count_stat(project)
      concat issues_opened_stat(project)
      concat content_tag :li, (content_tag :span, nil, class: 'octicon octicon-lock') if project.is_archived
    end
  end

  def issues_opened_stat(project)
    content_tag :li do
      content_tag :span, class: 'project-stat' do
        concat content_tag :span, nil, class: 'octicon octicon-issue-opened'
        concat project.issues_count
      end
    end
  end

  def member_count_stat(project)
    content_tag :li do
      content_tag :span, class: 'project-stat' do
        concat content_tag :span, nil, class: 'octicon octicon-organization'
        concat project.members_count
      end
    end
  end

  # Build a render for the star project' button.
  # @param [Project] project.
  def project_list_star_button(project)
    content_tag :div, class: 'star-project' do
      concat project.display_watch_button
      render_project_star_button(project)
    end
  end

  def render_project_star_button(project)
    if project.starred?
      concat star_project_link(project)
    else
      concat unstar_project_link(project)
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
            {class: "icon #{icon} starred star star-button btn btn-primary",
             method: :post, remote: true, data: {title: text, toggle: "tooltip"}})
  end


end