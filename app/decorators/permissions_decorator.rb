class PermissionsDecorator < ApplicationCollectionDecorator

  def new_link
    super(h.t(:link_new_permission), h.new_permission_path)
  end

  def display_collection
    controllers = context[:controller_list]
    permission_hash = Hash.new { |h, k| h[k] = [] }
    role = Role.eager_load(:permissions).where(name: context[:role_name].gsub('_', ' '))[0]
    selected_permissions = role.permissions.collect { |permission| permission.id }
    controllers.each do |controller|
      permission_hash[controller] = self.select { |permission| permission.controller.eql?(controller) }
    end
    h.list(permission_hash, selected_permissions)
  end
end
