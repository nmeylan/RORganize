class PermissionsDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_permission), h.new_permission_path)
  end

  # see #ApplicationCollectionDecorator::display_collection
  def display_collection
    controllers_groups = context[:controller_list]
    permission_hash = {}
    role = Role.eager_load(:permissions).where(name: context[:role_name].tr('_', ' '))[0]
    selected_permissions = role.permissions.collect { |permission| permission.id }
    controllers_groups.each do |group, controllers|
      controllers.each do |controller|
        permission_hash[group] ||= {}
        permission_hash[group][controller] = self.select { |permission| permission.controller.eql?(controller) }
      end
    end
    h.list(permission_hash, selected_permissions)
  end
end
