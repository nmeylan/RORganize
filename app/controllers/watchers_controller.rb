# Author: Nicolas Meylan
# Date: 13.09.14
# Encoding: UTF-8x
# File: watchers_controller.rb

class WatchersController < ApplicationController
  before_filter :find_watcher, only: [:create, :destroy]
  before_filter :check_permission, only: [:destroy, :create]
  include Rorganize::RichController::GenericCallbacks

  def create
    if @watcher
      success = @watcher.destroy
    else
      new_watcher
      success = @watcher.save
    end
    js_callback(success, [t(:successful_watched), "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}"])
  end

  def destroy
    if @watcher && @watcher.user_id.eql?(User.current.id)
      @model = @watcher.watchable
      js_callback(@watcher.destroy, [t(:successful_unwatched), "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}"])
    else
      new_watcher
      @watcher.is_unwatch = true
      respond_to do |format|
        if @watcher.save
          @model = @watcher.watchable
          format.js { respond_to_js response_header: :success, response_content: t(:successful_watched) }
        else
          format.js { respond_to_js action: 'do_nothing', response_header: :failure, response_content: "#{t(:successful_creation)} : #{@watcher.errors.full_messages.join(', ')}" }
        end
      end
    end
  end

  private

  def find_watcher
    @watcher = Watcher.find_by_watchable_id_and_watchable_type_and_user_id(params[:watchable_id], params[:watchable_type], User.current.id)
  end

  def check_permission
    controller = @watcher ? @watcher.watchable_type.pluralize : params[:watchable_type].pluralize
    project = params[:watchable_type].eql?('Project') ? nil : @project
    if User.current.allowed_to?('watch', controller, project)
      true
    else
      render_403
    end
  end

  def new_watcher
    @watcher = Watcher.new
    @watcher.watchable_id = params[:watchable_id]
    @watcher.watchable_type = params[:watchable_type]
    @watcher.author = User.current
    @watcher.project = @project
  end
end