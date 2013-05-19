# Author: Nicolas Meylan
# Date: 19 févr. 2013
# Encoding: UTF-8
# File: permissions_helper.rb

module PermissionsHelper

  def critical_permissions(permission_name)
    #Contains array with critical actions
    critical_permissions = ["destroy", "delete", "remove", "public"]
    critical_permissions.each do |permission|
      if permission_name.include?(permission) || permission_name.include?(permission.capitalize)
        return true
      end
    end
    return false
  end

  def critical_controllers(controller_name)
    critical_controllers =  ["administration", "permissions", "roles", "settings", "trackers"]
    critical_controllers.each do |controller|
      if controller_name.eql?(controller) || controller_name.eql?(controller.capitalize)
        return true
      end
    end
    return false
  end
end
