# Author: Nicolas Meylan
# Date: 23 mars 2013
# Encoding: UTF-8
# File: enabled_module.rb

class EnabledModule < ActiveRecord::Base
  belongs_to :project
end