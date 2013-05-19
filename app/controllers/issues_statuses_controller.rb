class IssuesStatusesController < ApplicationController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item("administration")}
  include ApplicationHelper
  def index
    @issues_statuses = IssuesStatus.select("*").includes(:enumeration).order("enumerations.position")
    @max = @issues_statuses.count
    respond_to do |format|
      format.html
    end
  end

  def new
    @status = IssuesStatus.new
    @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    respond_to do |format|
      format.html
    end
  end

  def edit
    @status = IssuesStatus.select("*").where(["id = ?",params[:id]]).includes(:enumeration).first
    @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    respond_to do |format|
      format.html
    end
  end

  def update
    @status = IssuesStatus.find_by_id(params[:id])
    @enumeration = @status.enumeration
    respond_to do |format|
      if @status.update_attributes(params[:issues_status]) && @enumeration.update_attributes(:name => params[:enumeration])
        flash[:notice] = t(:successful_update)
        format.html {redirect_to :action => 'index'}
      else
        @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
        @status.errors.add(:name, "can't be blank")
        format.html {render :action => 'edit'}
      end
    end
  end

  def create
    @status = IssuesStatus.new(params[:issues_status])
    @enumeration = Enumeration.new(:name => params[:enumeration], :opt => "ISTS")
    respond_to do |format|
      if @enumeration.save
        @status.enumeration_id = @enumeration.id
        if @status.save
          flash[:notice] = t(:successful_creation)
          format.html {redirect_to :action => 'index'}
        else
          @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
          format.html  { render :action => "new" }
          format.json  { render :json => @staus.errors,
            :status => :unprocessable_entity }
        end
      else
        @status.errors.add(:name, "can't be blank")
        @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
        format.html  { render :action => "new" }
      end
    end
  end

  def show

  end

  def destroy
    @status = IssuesStatus.find_by_id(params[:id])
    @status.destroy
    @issues_statuses = IssuesStatus.select("*").includes(:enumeration).order("enumerations.position")
    @max = @issues_statuses.count
    dec_position_on_destroy
    respond_to do |format|
      format.html {redirect_to :action => 'index'}
      format.js do
        render :update do |page|
          page.replace 'issues_statuses_content', :partial => 'issues_statuses/list'
          response.headers['flash-message'] = t(:successful_deletion)
        end
      end
    end
  end

  def change_position
    @issues_statuses = IssuesStatus.select("*").includes(:enumeration).order("enumerations.position")
    @status = @issues_statuses.select{|status| status.id.eql?(params[:id].to_i)}.first
    @max = @issues_statuses.count
    position = @status.enumeration.position
    respond_to do |format|
      if @status.enumeration.position == 1 && params[:operator].eql?("dec") ||
          @status.enumeration.position == @max && params[:operator].eql?("inc")
        @issues_statuses = IssuesStatus.select("*").includes(:enumeration).order("enumerations.position")
        format.js do
          render :update do |page|
            page.replace 'issues_statuses_content', :partial => 'issues_statuses/list'
            response.headers['flash-error-message'] = t(:text_negative_position)
          end
        end
      else
        if params[:operator].eql?("inc")
          o_status = @issues_statuses.select{|status| status.enumeration.position.eql?(position + 1)}.first
          o_status.enumeration.update_column(:position, position)
          @status.enumeration.update_column(:position, position + 1)
        else
          o_status = @issues_statuses.select{|status| status.enumeration.position.eql?(position - 1)}.first
          o_status.enumeration.update_column(:position, position)
          @status.enumeration.update_column(:position, position - 1)
        end
        @issues_statuses = IssuesStatus.select("*").includes(:enumeration).order("enumerations.position")
        format.js do
          render :update do |page|
            page.replace 'issues_statuses_content', :partial => 'issues_statuses/list'
            response.headers['flash-message'] = t(:successful_update)
          end
        end
      end
    end
  end

  private
  def dec_position_on_destroy
    position = @status.enumeration.position
    Enumeration.update_all "position = position - 1", "position > #{position} AND opt = 'ISTS'"
  end

end
