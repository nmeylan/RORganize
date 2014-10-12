# Author: Nicolas Meylan
# Date: 07.07.14
# Encoding: UTF-8
# File: roles_helper.rb

module RolesHelper
  # Build a list of roles.
  # @param [Array] collection of roles.
  def list(collection)
    collection_one_column_renderer(collection, 'role', 'roles.name')
  end
end