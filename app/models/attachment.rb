# Author: Nicolas Meylan
# Date: 11 nov. 2012
# Encoding: UTF-8
# File: attachment.rb

class Attachment < ActiveRecord::Base
  belongs_to :issue, :class_name => 'Issue'
  has_attached_file :file, :styles => lambda{ |a|
    ["image/jpeg", "image/bmp","image/png", "image/jpg", "image/gif"].include?( a.content_type ) ? {
      :thumb=> "100x100>",
      :small  => "150x150>",
      :medium => "300x300>",
      :large =>   "800x800>" }: {}
  },:size => { :in => 0..2.megabytes }
end