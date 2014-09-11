# Author: Nicolas Meylan
# Date: 19 févr. 2013
# Encoding: UTF-8
# File: permissions_helper.rb

module PermissionsHelper

  # Build a render of all permissions.
  # @param [Hash] permissions_hash : hash with following structure {group: [controller_name, ..]}.
  # @param [Array] selected_permissions : array of selected permissions' id.
  def list(permissions_hash, selected_permissions)
    form_tag({:action => 'update_permissions', :controller => 'permissions'}) do
      safe_concat content_tag :div, {id: 'project-tab'}, &Proc.new {
        permissions_table(permissions_hash[:project], selected_permissions, :project)
      }
      safe_concat content_tag :div, {id: 'adminstration-tab', style: 'display:none'}, &Proc.new {
        permissions_table(permissions_hash[:administration], selected_permissions, :administration)
      }
      safe_concat content_tag :div, {id: 'misc-tab', style: 'display:none'}, &Proc.new {
        permissions_table(permissions_hash[:misc], selected_permissions, :misc)
      }
      safe_concat submit_tag 'save'
    end
  end

  # Build a render of all permissions table.
  # @param [Array] permissions_array : array of controllers name.
  # @param [Array] selected_permissions : array of selected permissions' id.
  # @param [Symbol] group_name : the name of controllers group.
  def permissions_table(permissions_array, selected_permissions, group_name)
    content_tag :table, {class: 'permissions_list'} do
      safe_concat content_tag :tr, {class: 'header'}, &Proc.new {
        safe_concat content_tag :td, 'Controller', {class: 'permissions_list controller header'}
        safe_concat content_tag :td, {class: 'permissions_list header'}, &Proc.new {
          safe_concat (link_to glyph('', 'check'), '#', {class: 'check_all', id: "read_#{group_name}", 'cb_checked' => 'b', :title => 'check all'})
          safe_concat medium_glyph(t(:label_read), 'eye')
        }
        safe_concat content_tag :td, {class: 'permissions_list header'}, &Proc.new {
          safe_concat (link_to glyph('', 'check'), '#', {class: 'check_all', id: "create_#{group_name}", 'cb_checked' => 'b', :title => 'check all'})
          safe_concat medium_glyph(t(:label_create), 'plus')
        }
        safe_concat content_tag :td, {class: 'permissions_list header'}, &Proc.new {
          safe_concat (link_to glyph('', 'check'), '#', {class: 'check_all', id: "update_#{group_name}", 'cb_checked' => 'b', :title => 'check all'})
          safe_concat medium_glyph(t(:label_update), 'pencil')
        }
        safe_concat content_tag :td, {class: 'permissions_list header'}, &Proc.new {
          safe_concat (link_to glyph('', 'check'), '#', {class: 'check_all', id: "delete_#{group_name}", 'cb_checked' => 'b', :title => 'check all'})
          safe_concat medium_glyph(t(:label_delete), 'trashcan')
        }
        safe_concat content_tag :td, {class: 'permissions_list header'}, &Proc.new {
          safe_concat (link_to glyph('', 'check'), '#', {class: 'check_all', id: "misc_#{group_name}", 'cb_checked' => 'b', :title => 'check all'})
          safe_concat medium_glyph(t(:label_misc), '')
        }
      }
      safe_concat permissions_table_row_spacer(true)
      safe_concat permissions_table_row_spacer
      permissions_table_row_render(permissions_array, selected_permissions, group_name)
    end
  end

  # Build a render of a permissions' table row.
  # @param [Array] permissions_array : array of controllers name.
  # @param [Array] selected_permissions : array of selected permissions' id.
  # @param [Symbol] group_name : the name of controllers group.
  def permissions_table_row_render(permissions_array, selected_permissions, group_name)
    row_categories = Rorganize::PERMISSIONS_LIST_ROW_CATEGORIES
    permissions_array.sort { |x, y| x <=> y }.each do |controller, permissions|
      if permissions.any?
        safe_concat content_tag :tr, {class: "body #{controller}"}, &Proc.new {
          safe_concat content_tag :td, {class: 'permissions_list controller body'}, &Proc.new {
            safe_concat(link_to glyph('', 'check'), '#', {:id => 'check_all_'+controller.to_s, 'cb_checked' => 'b', :title => 'check all'})
            safe_concat controller
          }
          permissions_tmp = []
          row_categories.each do |category, actions|
            safe_concat content_tag :td, {class: "permissions_list body #{category} #{group_name}"}, &Proc.new {
              permissions.sort { |x, y| x.name <=> y.name }.collect do |permission|
                if permission.name.downcase.start_with?(*actions)
                  permissions_tmp << permission
                  content_tag :div, {class: 'permissions_list body permission'} do
                    safe_concat check_box_tag "[permissions][#{permission.controller}_#{permission.action}]", permission.id, selected_permissions.include?(permission.id)
                    safe_concat content_tag :label, permission.edit_link
                  end
                end
              end.join.html_safe
            }
          end
          safe_concat content_tag :td, {class: "permissions_list body misc #{group_name}"}, &Proc.new {
            (permissions - permissions_tmp).collect do |permission|
              content_tag :div, {class: 'permissions_list body permission'} do
                safe_concat check_box_tag "[permissions][#{permission.controller}_#{permission.action}]", permission.id, selected_permissions.include?(permission.id)
                safe_concat content_tag :label, permission.edit_link
              end
            end.join.html_safe
          }
        }
        safe_concat permissions_table_row_spacer(true)
        safe_concat permissions_table_row_spacer
      end
    end
  end

  # Build an empty row for table.
  # @param [Boolean] border : if false don't display a border, else display it.
  def permissions_table_row_spacer(border = false)
    content_tag :tr, {class: "permissions_list spacer body #{border ? 'border' : ''}"}, &Proc.new {
      safe_concat content_tag :td, nil
      safe_concat content_tag :td, nil
      safe_concat content_tag :td, nil
      safe_concat content_tag :td, nil
      safe_concat content_tag :td, nil
      safe_concat content_tag :td, nil
    }
  end

end
