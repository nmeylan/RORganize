# Author: Nicolas Meylan
# Date: 21.09.14
# Encoding: UTF-8
# File: preference.rb

class Preference < ActiveRecord::Base
  belongs_to :user
  belongs_to :enumeration
end