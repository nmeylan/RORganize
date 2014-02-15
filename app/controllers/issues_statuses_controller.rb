class IssuesStatusesController < ApplicationController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('administration') }
  include ApplicationHelper

  def index
    get_statuses
    respond_to do |format|
      format.html
    end
  end

  def new
    @status = IssuesStatus.new
    @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    respond_to do |format|
      format.html
    end
  end

  def edit
    @status = IssuesStatus.select('*').where(['id = ?', params[:id]]).includes(:enumeration).first
    @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    respond_to do |format|
      format.html
    end
  end

  def update
    @status = IssuesStatus.find_by_id(params[:id])
    @enumeration = @status.enumeration
    respond_to do |format|
      if @status.update_attributes(issue_statutes_params) && @enumeration.update_attributes(:name => enumeration_params[:name])
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'index' }
      else
        @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        @status.errors.add(:name, "can't be blank")
        format.html { render :action => 'edit' }
      end
    end
  end

  def create
    @status = IssuesStatus.new(issue_statutes_params)
    @enumeration = Enumeration.new(:name => enumeration_params[:name], :opt => 'ISTS')
    respond_to do |format|
      if @enumeration.save
        @status.enumeration_id = @enumeration.id
        if @status.save
          flash[:notice] = t(:successful_creation)
          format.html { redirect_to :action => 'index' }
        else
          @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
          format.html { render :action => 'new' }
          format.json { render :json => @staus.errors,
                               :status => :unprocessable_entity }
        end
      else
        @status.errors.add(:name, "can't be blank")
        @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        format.html { render :action => 'new' }
      end
    end
  end

  def show

  end

  def destroy
    @status = IssuesStatus.find_by_id(params[:id])
    @status.destroy
    get_statuses
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js { respond_to_js :locals => {:id => params[:id]}, :response_header => :success, :response_content => t(:successful_deletion) }
    end
  end

  def change_position
    issue_status = IssuesStatus.find_by_id(params[:id].to_i)
    saved = issue_status.change_position(params[:operator])
    get_statuses
    respond_to do |format|
      if saved
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_update) }
      else
        format.js { respond_to_js :response_header => :failure, :response_content => t(:text_negative_position) }
      end
    end
  end

  private
  def issue_statutes_params
    params.require(:issues_status).permit(IssuesStatus.permit_attributes)
  end

  def enumeration_params
    params.require(:enumeration).permit(Enumeration.permit_attributes)
  end

  def get_statuses
    @issues_statuses = IssuesStatus.includes(:enumeration).order('enumerations.position')
    @max = @issues_statuses.count
  end

end
