class IssuesStatusesController < ApplicationController
  include RichController
  before_action :check_permission
  before_action :find_status, only: [:update, :destroy, :edit, :change_position]
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  def index
    get_statuses
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def new
    @status = IssuesStatus.new(color: IssuesStatus::DEFAULT_OPENED_STATUS_COLOR)
    respond_to do |format|
      format.html { render :new, locals: {done_ratio: done_ratio} }
    end
  end

  def edit
    respond_to do |format|
      format.html { render :edit, locals: {done_ratio: done_ratio} }
    end
  end

  def update
    @enumeration = @status.enumeration
    respond_to do |format|
      if @status.update_attributes(issue_statutes_params) && @enumeration.update_attributes(name: enumeration_params[:name])
        flash[:notice] = t(:successful_update)
        format.html { redirect_to issues_statuses_path }
      else
        @status.errors.messages.merge!(@enumeration.errors.messages)
        error_generic_update_callback(format, @status, {done_ratio: done_ratio})
      end
    end
  end

  def create
    @status = IssuesStatus.create_status(enumeration_params[:name], issue_statutes_params)
    respond_to do |format|
      if @status.errors.messages.empty?
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to issues_statuses_path }
      else
        error_generic_create_callback(format, @status, {done_ratio: done_ratio})
      end
    end
  end

  def destroy
    @status.destroy
    get_statuses
    respond_to do |format|
      format.html { redirect_to issues_statuses_path }
      format.js { respond_to_js locals: {id: params[:id]}, response_header: :success, response_content: t(:successful_deletion) }
    end
  end

  def change_position
    saved = @status.change_position(params[:operator])
    get_statuses
    simple_js_callback(saved, :update, @status)
  end

  private
  def issue_statutes_params
    params.require(:issues_status).permit(IssuesStatus.permit_attributes)
  end

  def enumeration_params
    params.require(:enumeration).permit(Enumeration.permit_attributes)
  end

  def find_status
    @status = IssuesStatus.includes(:enumeration).find_by!(id: params[:id])
  end

  def get_statuses
    @issues_statuses_decorator = IssuesStatus.paginated(@sessions[:current_page], @sessions[:per_page], order('enumerations.position')).fetch_dependencies.decorate
  end

  def done_ratio
    range = 0..100
    range.step(10).map { |x| x }
  end

end
