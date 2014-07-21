# Author: Nicolas Meylan
# Date: 11 nov. 2012
# Encoding: UTF-8
# File: attachment.rb

class Attachment < ActiveRecord::Base
  include Rorganize::SmartRecords

  has_attached_file :file, {:url => "/system/:class/:object_type/:object_id/:id/:style/:hash.:extension",
                            :hash_secret => RORganize::Application.config.secret_attachment_key,
                            :styles => { :logo => '40x40', :thumb => '100x100>', :small => '150x150>', :medium => '300x300>', :large => '800x800>'}}

  Paperclip.interpolates :object_type do |attachment, _|
    attachment.instance.object_type.pluralize
  end
  Paperclip.interpolates :object_id do |attachment, _|
    attachment.instance.object_id
  end

  before_post_process :skip_non_image

  validates_attachment_content_type :file, :content_type => /\Aimage|application/
  # Validate filename
  validates_attachment_size :file, :in => 0..2.megabytes
  validates_attachment_file_name :file, :not => /.exe/

  def self.permit_attributes
    [:file, :tempfile, :original_filename, :content_type, :headers, :form_data, :name]
  end

  def icon_type
    if self.file_content_type
      if self.file_content_type.match(/application\/pdf/).nil?
        'file-media'
      else
        'file-pdf'
      end
    end
  end

  def caption
    self.name
  end

  def skip_non_image
    !file_content_type.match(/\Aimage/).nil?
  end

  def custom_uri
    "/system/:class/#{self.object_type}/:id/:style/:hash.:extension"
  end
end