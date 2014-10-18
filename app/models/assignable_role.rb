# Author: Nicolas Meylan
# Date: 18.10.14
# Encoding: UTF-8
# File: assignable_role.rb

class AssignableRole < ActiveRecord::Base
  belongs_to :role, class_name: 'Role'
  belongs_to :assignable_by_role, class_name: 'Role'
end