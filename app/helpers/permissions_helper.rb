# Author: Nicolas Meylan
# Date: 19 févr. 2013
# Encoding: UTF-8
# File: permissions_helper.rb

module PermissionsHelper

  # Build a render of all permissions.
  # @param [Hash] permissions_hash : hash with following structure {group: [controller_name, ..]}.
  # @param [Array] selected_permissions : array of selected permissions' id.
  def list(permissions_hash, selected_permissions)
    form_tag({action: 'update_permissions', controller: 'permissions'}) do
      concat permission_project_tab_render(permissions_hash, selected_permissions)
      concat permission_administration_tab_render(permissions_hash, selected_permissions)
      concat permission_misc_tab_render(permissions_hash, selected_permissions)
      concat submit_tag 'save'
    end
  end

  def permission_misc_tab_render(permissions_hash, selected_permissions)
    content_tag :div, {id: 'misc-tab', style: 'display:none'} do
      permissions_table(permissions_hash[:misc], selected_permissions, :misc)
    end
  end

  def permission_administration_tab_render(permissions_hash, selected_permissions)
    content_tag :div, {id: 'administration-tab', style: 'display:none'} do
      permissions_table(permissions_hash[:administration], selected_permissions, :administration)
    end
  end

  def permission_project_tab_render(permissions_hash, selected_permissions)
    content_tag :div, {id: 'project-tab'} do
      permissions_table(permissions_hash[:project], selected_permissions, :project)
    end
  end

  # Build a render of all permissions table.
  # @param [Array] permissions_array : array of controllers name.
  # @param [Array] selected_permissions : array of selected permissions' id.
  # @param [Symbol] group_name : the name of controllers group.
  def permissions_table(permissions_array, selected_permissions, group_name)
    content_tag :table, {class: 'permissions-list'} do
      concat permission_table_header_render(group_name)
      concat permissions_table_row_spacer(true)
      concat permissions_table_row_spacer
      permissions_table_rows_render(permissions_array, selected_permissions, group_name) unless permissions_array.nil?
    end
  end

  def permission_table_header_render(group_name)
    content_tag :tr, {class: 'header'} do
      concat content_tag :td, 'Controller', {class: 'permissions-list controller header'}
      concat permission_table_header_col_render('read', t(:label_read), group_name, 'eye')
      concat permission_table_header_col_render('create', t(:label_create), group_name, 'plus')
      concat permission_table_header_col_render('update', t(:label_update), group_name, 'pencil')
      concat permission_table_header_col_render('delete', t(:label_delete), group_name, 'trashcan')
      concat permission_table_header_col_render('misc', t(:label_misc),group_name, '')
    end
  end

  def permission_table_header_col_render(col_name, label, group_name, glyph_name)
    content_tag :td, {class: "permissions-list header #{col_name}"} do
      concat (link_to glyph('', 'check'), '#', {class: 'check-all', id: "#{col_name}-#{group_name}", 'cb_checked' => 'b', title: 'check all'})
      concat medium_glyph(label, glyph_name)
    end
  end

  # Build a render of a permissions' table row.
  # @param [Array] permissions_array : array of controllers name.
  # @param [Array] selected_permissions : array of selected permissions' id.
  # @param [Symbol] group_name : the name of controllers group.
  def permissions_table_rows_render(permissions_array, selected_permissions, group_name)
    col_categories = Rorganize::PERMISSIONS_LIST_COL_CATEGORIES
    permissions_array.sort { |x, y| x <=> y }.each do |controller, permissions|
      if permissions.any?
        concat permissions_table_row_render(col_categories, controller, group_name, permissions, selected_permissions)
        concat permissions_table_row_spacer(true)
        concat permissions_table_row_spacer
      end
    end
  end


  # @param [Hash] col_categories hash with following structure :  e.g {read: %w(view access consult use), ..}.
  # @param [String] controller name.
  # @param [Symbol] group_name : the name of controllers group (e.g : projects, administrations, misc).
  # @param [Array] permissions collection of permissions for a specific controller.
  # @param [Array] selected_permissions collection of checked permissions.
  def permissions_table_row_render(col_categories, controller, group_name, permissions, selected_permissions)
    content_tag :tr, {class: "body #{controller}"} do
      concat permission_table_first_column_render(controller)
      permissions_tmp = []
      permission_table_column_render(group_name, permissions, permissions_tmp, col_categories, selected_permissions)
      concat permission_table_extra_column_render(group_name, permissions, permissions_tmp, selected_permissions)
    end
  end

  # @param [Symbol] group_name : the name of controllers group (e.g : projects, administrations, misc).
  # @param [Array] permissions collection of permissions for a specific controller.
  # @param [Array] permissions_tmp collection of permission already rendered.
  # @param [Array] selected_permissions collection of checked permissions.
  def permission_table_extra_column_render(group_name, permissions, permissions_tmp, selected_permissions)
    content_tag :td, {class: "permissions-list body misc #{group_name}"} do
      (permissions - permissions_tmp).collect do |permission|
        permission_table_column_content(permission, selected_permissions)
      end.join.html_safe
    end
  end

  # @param [String] controller name.
  def permission_table_first_column_render(controller)
    content_tag :td, {class: 'permissions-list controller body'} do
      concat(link_to glyph('', 'check'), '#', {id: 'check-all-'+controller.to_s, 'cb_checked' => 'b', title: 'check all'})
      concat controller
    end
  end

  # @param [Symbol] group_name : the name of controllers group (e.g : projects, administrations, misc).
  # @param [Array] permissions collection of permissions for a specific controller.
  # @param [Array] permissions_tmp collection of permission already rendered.
  # @param [Hash] col_categories hash with following structure :  e.g {read: %w(view access consult use), ..}.
  # @param [Array] selected_permissions collection of checked permissions.
  def permission_table_column_render(group_name, permissions, permissions_tmp, col_categories, selected_permissions)
    col_categories.each do |category, actions|
      concat content_tag :td, {class: "permissions-list body #{category} #{group_name}"}, &Proc.new {
        render_column_permissions(actions, permissions, permissions_tmp, selected_permissions)
      }
    end
  end

  # @param [Array] actions : list of actions names include in the group name.
  # @param [Array] permissions collection of permissions for a specific controller.
  # @param [Array] permissions_tmp collection of permission already rendered.
  # @param [Array] selected_permissions collection of checked permissions.
  def render_column_permissions(actions, permissions, permissions_tmp, selected_permissions)
    permissions.sort { |x, y| x.name <=> y.name }.collect do |permission|
      if permission.name.downcase.start_with?(*actions)
        permissions_tmp << permission
        permission_table_column_content(permission, selected_permissions)
      end
    end.join.html_safe
  end

  # @param [Permission] permission collection of permissions for a specific controller.
  # @param [Array] selected_permissions collection of checked permissions.
  def permission_table_column_content(permission, selected_permissions)
    content_tag :div, {class: 'permissions-list body permission'} do
      concat check_box_tag "[permissions][#{permission.controller}_#{permission.action}]", permission.id, selected_permissions.include?(permission.id)
      concat content_tag :label, permission.edit_link
    end
  end

  # Build an empty row for table.
  # @param [Boolean] border : if false don't display a border, else display it.
  def permissions_table_row_spacer(border = false)
    content_tag :tr, {class: "permissions-list spacer body #{border ? 'border' : ''}"} do
      6.times do
        concat content_tag :td, nil
      end
    end
  end

end
