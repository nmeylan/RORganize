require 'shared/activities'
require 'issues/issue_overview_hash'
class RorganizeController < ApplicationController
  helper ProjectsHelper
  helper IssuesHelper
  helper UsersHelper
  include Rorganize::ActivityManager
  before_filter { |c| c.top_menu_item('home') }
  helper_method :sort_column, :sort_direction


  def index
    respond_to do |format|
      if current_user.nil?
        format.html { render :action => 'index' }
      else
        projects_decorator = User.current.owned_projects('starred').decorate(context: {allow_to_star: false})
        overview_object_assigned = IssueOverviewHash.new(Issue.where(assigned_to_id: User.current.id).where('issues_statuses.is_closed = false').fetch_dependencies, {project: :assigned_to})
        overview_object_submitted = IssueOverviewHash.new(Issue.where(author_id: User.current.id).where('issues_statuses.is_closed = false').fetch_dependencies, {project: :author})
        format.html { render action: 'index', locals: {projects_decorator: projects_decorator, overview_object_assigned: overview_object_assigned, overview_object_submitted: overview_object_submitted} }
      end
    end
  end

  def view_profile
    @user_decorator = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(params[:user])
    if @user_decorator
      @user_decorator = @user_decorator.decorate
      init_activities_sessions
      activities_data = selected_filters
      if @sessions[:activities][:types].include?('NIL')
        @activities = Activities.new([])
      else
        activities_types = @sessions[:activities][:types]
        activities_period = @sessions[:activities][:period]
        from_date = @sessions[:activities][:from_date]
        @activities = Activities.new(@user_decorator.activities(activities_types, activities_period, from_date), @user_decorator.comments(activities_types, activities_period, from_date))
      end
      respond_to do |format|
        format.html { render :action => 'view_profile', locals: activities_data }
        format.js { respond_to_js action: 'activity', locals: activities_data }
      end
    else
      render_404
    end
  end

  def activity
    view_profile
  end

  def preview_markdown
    respond_to do |format|
      format.json { render json: markdown_to_html(params[:content]) }
    end
  end

  def task_list_action_markdown
    element_types = {'Comment' => Comment, 'Issue' => Issue, 'Document' => Document}
    params.require(:is_check)
    params.require(:element_type)
    params.require(:element_id)
    params.require(:check_index)
    element_type = element_types[params[:element_type]]
    element = element_type.find_by_id(params[:element_id]) if element_type
    unless element.nil?
      if params[:element_type].eql?('Comment') && (User.current.allowed_to?('edit_comment_not_owner', 'comments', @project) || element.user_id.eql?(User.current.id))
        content = element.content
      elsif (params[:element_type].eql?('Issue') && (User.current.allowed_to?('edit_not_owner', 'issues', @project) || element.author.eql?(User.current))) || (params[:element_type].eql?('Document') && (User.current.allowed_to?('edit', 'documents', @project)))
        content = element.description
      else #User try to cheat.
        content = nil
        message = "Don't try to brain the master. You now you haven't the permission to perform this action!"
        header = :failure
      end
      unless content.nil?
        count = -1
        content.gsub!(/- \[(\w|\s)\]/) do |task|
          count += 1
          if count == params[:check_index].to_i
            params[:is_check].eql?('true') ? '- [x]' : '- [ ]'
          else
            task
          end
        end
        if params[:element_type].eql?('Comment')
          element.update_column(:content, content)
        elsif params[:element_type].eql?('Issue') || params[:element_type].eql?('Document')
          element.update_column(:description, content)
        end
        message = t(:successful_update)
        header = :success
      end
    end
    respond_to do |format|
      format.js { respond_to_js action: 'do_nothing', response_header: header, response_content: message}
    end
  end

  def about
    respond_to do |format|
      format.html
    end
  end

  private
  def sort_column
    params[:sort] ? params[:sort] : 'issues.id'
  end

  def sort_direction
    params[:direction] ? params[:direction] : 'DESC'
  end

  def load_activities

  end
end
