# Author: Nicolas Meylan
# Date: 12 oct. 2012
# Encoding: UTF-8
# File: permission.rb

class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles, :class_name => 'Role'

  validates :name, :controller, :action, :presence => true
  validates :name, :uniqueness => true

  def self.permit_attributes
    [:name, :action, :controller]
  end


  def self.permission_list(role_name)
    controllers = Permission.controller_list
    permission_hash = Hash.new{|h,k| h[k] = {}}
    role = Role.find_by_name(role_name.gsub('_', ' '))
    selected_permissions = role.permissions.collect{|permission| permission.id}
    permissions = Permission.select('*')
    tmp_ary = []
    tmp_hash = {}
    controllers.each do |controller|
      tmp_ary = permissions.select{ |permission| permission.controller.eql?(controller)}
      tmp_ary.each do |permission|
        tmp_hash[permission.name] = permission.id
      end
      permission_hash[controller] = tmp_hash
      tmp_hash = {}
    end
    {:permission_hash => permission_hash, :selected_permissions => selected_permissions}
  end

  def self.controller_list
    controllers =  Rails.application.routes.routes.collect{|route| route.defaults[:controller]}
    unused_controller = %w(rorganize my)
    controllers = controllers.uniq!.select{|controller_name| controller_name && !controller_name.match(/.*\/.*/) && !unused_controller.include?(controller_name)}
    controllers.collect! do |controller|
      controller = controller.capitalize
    end
    controllers
  end

end
