class ProjectsController < ApplicationController
  before_filter {|c| c.top_menu_item("projects")}
  #GET /projects/
  def index
    @members = current_user.members.includes(:project => [:attachments])
    if current_user.act_as_admin?
      @allowed_projects = Project.find(:all, :conditions => ["is_archived = ?", false])
      respond_to do |format|
        format.html
      end
    else
      allowed_project_ids = @members.collect{|member| member.project_id}
      @allowed_projects = Project.find(allowed_project_ids)
      @allowed_projects.delete_if{ |project| project.is_archived }
      respond_to do |format|
        format.html
      end
    end
  end


end
