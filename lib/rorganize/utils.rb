# Author: Nicolas Meylan
# Date: 23.11.14
# Encoding: UTF-8
# File: utils.rb
module Rorganize
  module Utils
    def self.class_name_to_human_name(class_name)
      i = 0
      class_name.pluralize.gsub(/([A-Z])/){|occurrence|  i += 1; i == 1 ? occurrence : ' '+occurrence }.capitalize
    end

  end
end