# Author: Nicolas Meylan
# Date: 13.09.14
# Encoding: UTF-8x
# File: watchers_controller.rb

class WatchersController < ApplicationController
  include GenericCallbacks

  before_action :find_watcher, only: [:toggle]
  before_action :check_permission, only: [:toggle]

  def toggle
    if @watcher
      @model = @watcher.watchable
      if @watcher.is_unwatch
        result = @watcher.update_attribute(:is_unwatch, false)
        js_callback(result, [t(:successful_watched), "#{t(:failure_creation)} : #{@watcher.errors.full_messages.join(', ')}"], 'create')
      elsif @model.parent_watch_by?(User.current) && !@watcher.is_unwatch
        result = @watcher.update_attribute(:is_unwatch, true)
        js_callback(result, [t(:successful_unwatched), "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}"], 'destroy')
      else
        result = @watcher.destroy
        js_callback(result, [t(:successful_unwatched), "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}"], 'destroy')
      end
    else
      @watcher = Watcher.new(watchable_id: params[:watchable_id], watchable_type: params[:watchable_type],
                             author: User.current, project: @project)
      if @watcher.watchable.parent_watch_by?(User.current)
        @watcher.is_unwatch = true
        result = @watcher.save
        @model = @watcher.watchable
        js_callback(result, [t(:successful_unwatched), "#{t(:failure_deletion)} : #{@watcher.errors.full_messages.join(', ')}"], 'destroy')
      else
        result = @watcher.save
        @model = @watcher.watchable
        js_callback(result, [t(:successful_watched), "#{t(:failure_creation)} : #{@watcher.errors.full_messages.join(', ')}"], 'create')
      end
    end
  end

  private

  def find_watcher
    @watcher = Watcher.find_by_watchable_id_and_watchable_type_and_user_id(params[:watchable_id], params[:watchable_type], User.current.id)
  end

  def check_permission
    controller = Rorganize::Utils::class_name_to_controller_name(@watcher ? @watcher.watchable_type : params[:watchable_type])
    project = params[:watchable_type].eql?('Project') ? nil : @project
    raise ActionController::RoutingError.new('Forbidden') unless User.current.allowed_to?('watch', controller, project)
  end
end