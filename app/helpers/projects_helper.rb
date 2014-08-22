module ProjectsHelper
  include JournalsHelper

  def members_list(members_hash)
    content_tag :div do
      members_hash.collect do |role, members|
        safe_concat content_tag :h4, role
        safe_concat content_tag :ul, members.collect { |member| content_tag :li, member.caption }.join.html_safe
      end.join.html_safe
    end
  end


  def project_list(projects, allow_to_star)
    content_tag :ul, class: "project_list #{allow_to_star ? 'sortable' : '' }" do
      projects.collect do |project|
        content_tag :li, class: "#{project.is_archived ? 'archived' : ''} project", id: project.id do
          safe_concat project_stats(project).html_safe
          safe_concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
          safe_concat content_tag :p, class: 'project_last_activity', &Proc.new {
            project.last_activity_info
          }
          project_list_star_button(project) if allow_to_star
        end
      end.join.html_safe
    end
  end

  def project_stats(project)
    content_tag :ul, class: 'project_stats' do
      safe_concat content_tag :li, (content_tag :span, project.members_count, class: 'octicon octicon-organization')
      safe_concat content_tag :li, (content_tag :span, project.issues_count, class: 'octicon octicon-tag')
      safe_concat content_tag :li, (content_tag :span, nil, class: 'octicon octicon-lock') if project.is_archived
    end
  end

  def project_list_star_button(project)
    safe_concat content_tag :div, class: 'star_project', &Proc.new {
      button_tag &Proc.new {
        if project.starred?
          link_to(glyph(t(:link_unstar), 'star'), star_project_profile_path(project.id), {:class => 'icon icon-fav starred star', :method => :post, :remote => true})
        else
          link_to(glyph(t(:link_star), 'star'), star_project_profile_path(project.id), {:class => 'icon icon-fav-off star', :method => :post, :remote => true})
        end
      }
    }
  end


end