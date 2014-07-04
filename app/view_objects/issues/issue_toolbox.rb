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
    if @user.allowed_to?('change_assigned', 'Issues', @project)
      @menu[:assigned_to].caption = h.t(:field_assigned_to)
      @menu[:assigned_to].glyph_name = 'person'
      @menu[:assigned_to].all = @project.members.collect { |member| member.user }
      @menu[:assigned_to].currents = @collection.collect { |issue| issue.assigned_to }.uniq
      @menu[:assigned_to].attribute_name = 'assigned_to_id'
    end

    if @user.allowed_to?('change_version', 'Issues', @project)
      @menu[:version].caption = h.t(:field_version)
      @menu[:version].glyph_name = 'clippy'
      @menu[:version].all = @project.versions.collect { |version| version }
      @menu[:version].currents = @collection.collect { |issue| issue.version }.uniq
      @menu[:version].attribute_name = 'version_id'
    end

    if @user.allowed_to?('change_status', 'Issues', @project)
      @menu[:status].caption = h.t(:field_status)
      @menu[:status].glyph_name = 'dashboard'
      @menu[:status].all = @user.allowed_statuses(@project).collect { |status| status }
      @menu[:status].currents = @collection.collect { |issue| issue.status }.uniq
      @menu[:status].attribute_name = 'status_id'
    end

    if @user.allowed_to?('change_category', 'Issues', @project)
      @menu[:category].caption = h.t(:field_category)
      @menu[:category].glyph_name = 'package'
      @menu[:category].all = @project.categories.collect { |category| category }
      @menu[:category].currents = @collection.collect { |issue| issue.category }.uniq
      @menu[:category].attribute_name = 'category_id'
    end

    if @user.allowed_to?('change_progress', 'Issues', @project)
      @menu[:done].caption = h.t(:field_done)
      @menu[:done].glyph_name = 'pulse'
      @menu[:done].all = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
      @menu[:done].currents = @collection.collect { |issue| issue.done }.uniq
      @menu[:done].attribute_name = 'done'
    end

    if @user.allowed_to?('edit', 'Issues', @project)
      @extra_actions << h.link_to(h.glyph(h.t(:link_edit), 'pencil'), h.edit_issue_path(@project.slug, @collection_ids[0])) if @collection.size == 1
    end
    if @user.allowed_to?('destroy', 'Issues', @project)
      @extra_actions << h.link_to(h.glyph(h.t(:link_delete), 'trashcan'), '#', {:class => 'icon icon-del', :id => 'open_delete_overlay'})
    end
  end

end