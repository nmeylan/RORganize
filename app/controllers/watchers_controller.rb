# Author: Nicolas Meylan
# Date: 13.09.14
# Encoding: UTF-8x
# File: watchers_controller.rb

class WatchersController < ApplicationController
  before_filter :find_watcher, :only => [:destroy]
  before_filter :check_permission, :only => [:destroy, :create]

  def create
    @watcher = Watcher.new(watcher_params)
    @watcher.author = User.current
    respond_to do |format|
      if @watcher.save
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_creation) }
      else
        format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => "#{t(:failure_creation)} : #{@watcher.errors.full_messages.join(', ')}" }
      end
    end
  end

  def destroy
    if @watcher.user_id.eql? User.current.id
      @model = @watcher.watchable
      respond_to do |format|
        if @watcher.destroy
          format.js { respond_to_js :response_header => :success, :response_content => t(:successful_deletion) }
        else
          format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}" }
        end
      end
    end
  end

  private
  def watcher_params
    params.require(:watcher).permit(Watcher.permit_attributes)
  end

  def find_watcher
    @watcher = Watcher.find_by_id(params[:id])
  end

  def check_permission
    controller = @watcher ? @watcher.watchable_type.pluralize : params[:watcher][:watchable_type].pluralize
    if User.current.allowed_to?('watch', controller, @project)
      true
    else
      render_403
    end
  end
end