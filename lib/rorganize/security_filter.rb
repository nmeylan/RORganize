# Author: Nicolas Meylan
# Date: 20.08.14
# Encoding: UTF-8
# File: security_filter.rb
module Rorganize
  module SecurityFilter
    def self.included(base)
      base.before_filter :find_project
      base.before_filter :set_action_alias
    end


    def check_permission
      if User.current.allowed_to?(find_action_alias(action_name), controller_name, @project)
        true
      else
        render_403
      end
    end

    def check_not_owner_permission
      if check_owner # must be define in controller
        true
      else
        action = "#{find_action_alias(action_name)}_not_owner"
        if User.current.allowed_to?(action, controller_name, @project)
          true
        else
          render_403
        end
      end
    end


    def drill_params(hash)
      hash.each do |k, v|
        throw(:project_id, v) if k.eql?('project_id')
        if v.is_a?(Hash)
          drill_params(v)
        end
      end
    end

    def find_project
      project_id = catch(:project_id) do
        drill_params(params)
      end
      if project_id.is_a? String
        @project = Project.includes(:attachments).references(:attachments).where(slug: project_id) #this always return 1 result. Don't use .first(AR) because it generate two query (due to ActiveRecord::FinderMethods::apply_join_dependency(..))
        @project = @project.to_a.first
        gon.project_id = @project.slug
        render_404 if @project.nil?
      end
    rescue => e
      render_404
    end


    def set_action_alias
      @aliases = {update: :edit, create: :new, toolbox: :edit}
    end

    def add_action_alias=(hash)
      @aliases.merge!(hash)
    end

    def find_action_alias(action)
      action = action.to_sym
      if @aliases.keys.include?(action)
        @aliases[action]
      else
        action
      end
      action.to_s
    end
  end
end