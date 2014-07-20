# Author: Nicolas Meylan
# Date: 11 nov. 2012
# Encoding: UTF-8
# File: attachment.rb

class Attachment < ActiveRecord::Base
  include Rorganize::SmartRecords

  has_attached_file :file, :styles => {
      :logo => '40x40',
      :thumb => '100x100>',
      :small => '150x150>',
      :medium => '300x300>',
      :large => '800x800>'}

  validates_attachment_content_type :file, :content_type => %w(image/jpeg image/bmp image/png image/jpg image/gif application/pdf)
  # Validate filename
  validates_attachment_size :file, :in => 0..2.megabytes
  validates_attachment_file_name :file, :not => /.exe/

  def self.permit_attributes
    [:file, :tempfile, :original_filename, :content_type, :headers, :form_data, :name]
  end

  def icon_type
    if self.file_content_type.gsub(/\//, '-').eql?('pdf')
      'octicon-file-pdf'
    else
      'octicon-file-media'
    end
  end

  def caption
    self.name
  end
end