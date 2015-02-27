# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issue_toolbox.rb

require 'shared/toolbox'

class IssueToolbox < Toolbox
  include Draper::ViewHelpers

  def initialize(collection, project, user)
    super(collection, user, {path: h.toolbox_issues_path(project.slug)})
    @project = project
    build_menu
  end

  def build_menu
    build_menu_assigned_to
    build_menu_version
    build_menu_status
    build_menu_category
    build_menu_done

    add_extra_action_edit('Issues', h.edit_issue_path(@project.slug, @collection_ids[0]))
    add_extra_action_delete('Issues')
  end

  def build_menu_done
    if @user.allowed_to?('change_progress', 'Issues', @project)
      @menu[:done].caption = h.t(:field_done)
      @menu[:done].glyph_name = Rorganize::ACTION_ICON[:done]
      @menu[:done].all = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
      @menu[:done].currents = @collection.collect { |issue| issue.done }.uniq
      @menu[:done].attribute_name = 'done'
    end
  end

  def build_menu_category
    if allowed_to_change('category')
      generic_toolbox_menu_builder(h.t(:field_category), :categories, :category_id, @project.categories.sort_by{|category| category.caption.downcase}, Proc.new(&:category), true)
    end
  end

  def build_menu_status
    if allowed_to_change('status')
      generic_toolbox_menu_builder(h.t(:field_status), :status, :status_id, @user.allowed_statuses(@project), Proc.new(&:status))
    end
  end

  def build_menu_version
    if allowed_to_change('version')
      generic_toolbox_menu_builder(h.t(:field_version), :versions, :version_id, @project.active_versions, Proc.new(&:version), true)
    end
  end

  def build_menu_assigned_to
    if allowed_to_change('assigned')
      generic_toolbox_menu_builder(h.t(:field_assigned_to), :assigned_to, :assigned_to_id, @project.real_members(&:user).sort_by(&:caption), Proc.new(&:assigned_to), true)
    end
  end

  def allowed_to_change(attr_name)
    @user.allowed_to?("change_#{attr_name}", 'Issues', @project)
  end

end