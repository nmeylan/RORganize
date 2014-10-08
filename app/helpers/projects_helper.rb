module ProjectsHelper
  include JournalsHelper

  # Build a list of members group by their role in project.
  # @param [Hash] members_hash  with following structure {role: members}.
  def members_list(members_hash)
    content_tag :div do
      members_hash.collect do |role, members|
        content_tag :div, class: 'members-block' do
          safe_concat content_tag :h4, "#{role}", {class: 'badge badge-role'}
          safe_concat content_tag :span, members.collect { |member| member.user.decorate.user_link(true) }.join(', ').html_safe, class: 'members-grouped-by-role'
        end
      end.join.html_safe
    end
  end

  # Build a list of projects.
  # @param [Array] projects.
  # @param [boolean] allow_to_star : if true user can star projects from the list, else the star button is hidden.
  def project_list(projects, allow_to_star)
    content_tag :ul, class: "fancy-list project-list #{allow_to_star ? 'sortable' : '' }" do
      projects.collect do |project|
        content_tag :li, class: "fancy-list-item project #{project.is_archived ? 'archived' : ''}", id: project.slug do
          safe_concat project_stats(project).html_safe
          safe_concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
          safe_concat content_tag :p, class: 'bottom-list-content project-last-activity', &Proc.new {
            project.last_activity_info
          }
          project_list_star_button(project) if allow_to_star && current_user
        end
      end.join.html_safe
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
    safe_concat content_tag :div, class: 'star-project', &Proc.new {
      safe_concat project.display_watch_button
      if project.starred?
        safe_concat link_to(glyph(t(:link_unstar), 'star'), star_project_profile_path(project.slug), {class: 'icon icon-fav starred star tooltipped tooltipped-s star-button button', :method => :post, :remote => true, label: t(:text_unstar)})
      else
        safe_concat link_to(glyph(t(:link_star), 'star'), star_project_profile_path(project.slug), {class: 'icon icon-fav-off star tooltipped tooltipped-s star-button button', :method => :post, :remote => true, label: t(:text_star)})
      end

    }

  end


end