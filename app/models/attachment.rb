# Author: Nicolas Meylan
# Date: 11 nov. 2012
# Encoding: UTF-8
# File: attachment.rb

class Attachment < ActiveRecord::Base
  include Rorganize::SmartRecords

  has_attached_file :avatar, {:url => "/system/:class/:object_type/:object_id/:id/:style/:hash.:extension",
                              :hash_secret => RORganize::Application.config.secret_attachment_key,
                              :styles => {:thumb => '40x40', :very_small => '16x16>', :small => '100x100>', :medium => '150x150>'},
                              convert_options: {very_small: "\\( +clone  -alpha extract " +
                                  "-draw 'fill black polygon 0,0 0,#{5} #{5},0 fill white circle #{5},#{5} #{5},0' " +
                                  "\\( +clone -flip \\) -compose Multiply -composite " +
                                  "\\( +clone -flop \\) -compose Multiply -composite " +
                                  "\\) -alpha off -compose CopyOpacity -composite "}}
  has_attached_file :file, {:url => "/system/:class/:object_type/:object_id/:id/:style/:hash.:extension",
                            :hash_secret => RORganize::Application.config.secret_attachment_key,
                            :styles => {:logo => '40x40', :thumb => '100x100>', :small => '150x150>', :medium => '300x300>', :large => '800x800>'}}

  Paperclip.interpolates :object_type do |attachment, _|
    attachment.instance.object_type.pluralize
  end
  Paperclip.interpolates :object_id do |attachment, _|
    attachment.instance.object_id
  end

  before_post_process :skip_non_image

  validates_attachment_size :avatar, :in => 0..2.megabytes
  validates_attachment_file_name :avatar, {:not => /.exe/, message: 'Errors'}
  validates_attachment_content_type :avatar, {content_type: /\Aimage/, message: 'Errors'}

  validates_attachment_content_type :file, {content_type: /\Aimage|application\/pdf|text/, message: 'Errors'}
  validates_attachment_size :file, :in => 0..2.megabytes
  validates_attachment_file_name :file, {:not => /.exe/, message: 'Errors'}


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

  def avatar_file_size
    self.file_file_size
  end

  def avatar_file_name
    self.file_file_name
  end

  def avatar_content_type
    self.file_content_type
  end

  def avatar_file_size=(size)
    self.file_file_size = size
  end

  def avatar_file_name=(name)
    self.file_file_name = name
  end

  def avatar_content_type=(type)
    self.file_content_type = type
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

  private
  def border_radius
    radius = 3
    "\\( +clone  -alpha extract " +
        "-draw 'fill black polygon 0,0 0,#{radius} #{radius},0 fill white circle #{radius},#{radius} #{radius},0' " +
        "\\( +clone -flip \\) -compose Multiply -composite " +
        "\\( +clone -flop \\) -compose Multiply -composite " +
        "\\) -alpha off -compose CopyOpacity -composite "
  end

end