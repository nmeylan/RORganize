# Author: Nicolas Meylan
# Date: 23.11.14
# Encoding: UTF-8
# File: utils.rb
module Rorganize
  module Utils
    def self.class_name_to_human_name(class_name)
      self.class_name_to(class_name, ' ')
    end

    def self.class_name_to_controller_name(class_name)
      self.class_name_to(class_name, '_')
    end

    private
    def self.class_name_to(class_name, char)
      i = 0
      class_name.pluralize.gsub(/([A-Z])/){|occurrence|  i += 1; i == 1 ? occurrence : char+occurrence }.capitalize
    end

  end
end