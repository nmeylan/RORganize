# Author: Nicolas Meylan
# Date: 19 févr. 2013
# Encoding: UTF-8
# File: permissions_helper.rb

module PermissionsHelper

  def critical_controllers(controller_name)
    critical_controllers = %w(administration permissions roles settings trackers)
    critical_controllers.include?(controller_name.downcase)
  end

  def list(permissions_hash, selected_permissions)
    form_tag({:action => 'update_permissions', :controller => 'permissions'}) do
      safe_concat content_tag :div, class: 'box', &Proc.new {
        permissions_hash.sort { |x, y| x <=> y }.collect do |controller, permissions|
          safe_concat content_tag :fieldset, &Proc.new {
            safe_concat content_tag :legend, &Proc.new {
              safe_concat(link_to glyph('', 'check'), '#', {:id => 'check_all_'+controller.to_s, 'cb_checked' => 'b', :title => 'check all'})
              safe_concat(content_tag :span, nil, {class: 'octicon octicon-alert'}) if critical_controllers(controller)
              safe_concat(link_to controller, '#', {:class => 'icon icon-expanded toggle', :id => controller})
            }
            safe_concat content_tag :div, class: "content #{controller}", &Proc.new {
              permissions.collect do |permission|
                safe_concat check_box_tag "[permissions][#{permission.controller}_#{permission.action}]", permission.id, selected_permissions.include?(permission.id)
                safe_concat content_tag :label, permission.edit_link
              end.join.html_safe
            }
          }
        end.join.html_safe
      }
      safe_concat submit_tag 'save'
    end
  end
end
