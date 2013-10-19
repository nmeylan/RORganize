class ProjectsController < ApplicationController
  before_filter {|c| c.top_menu_item('projects')}
  #GET /projects/
  def index
    unless params[:filter].nil?
      session['project_selection_filter'] = params[:filter]
    end
    if session['project_selection_filter'].nil?
      session['project_selection_filter'] = 'all'
    end
    if current_user.act_as_admin?
      case session['project_selection_filter']
      when 'opened'
        projects = Project.where(:is_archived => false)
        when 'archived'
        projects = Project.where(:is_archived => true)
        when 'starred'
        projects = current_user.starred_projects
      else
        projects = Project.find(:all)
      end
    else
      case session['project_selection_filter']
      when 'opened'
        projects = current_user.opened_projects
        when 'archived'
        projects = current_user.archived_projects
        when 'starred'
        projects = current_user.starred_projects
      else
        projects = current_user.projects
      end
      
    end
    respond_to do |format|
        format.html {render :action => 'index', :locals => {:projects => projects} }
        format.js {
          render :update do |page|
            page.replace 'projects', :partial => 'projects/list', :locals => {:allow_to_star => false, :projects => projects}
          end
        }
      end
  end


end
