# Author: Nicolas Meylan
# Date: 15.09.14
# Encoding: UTF-8
# File: avatar.rb

class Avatar < ActiveRecord::Base
  self.table_name = 'attachments'
  has_attached_file :avatar, {url: '/system/attachments/:attachable_type/:attachable_id/:id/:style/:file_name',
                              hash_secret: RORganize::Application.config.secret_attachment_key,
                              styles: {thumb: '50x50', very_small: '20x20>', small: '100x100>', medium: '150x150>'}}
  Paperclip.interpolates :attachable_type do |attachment, _|
    attachment.instance.attachable_type.pluralize
  end
  Paperclip.interpolates :attachable_id do |attachment, _|
    attachment.instance.attachable_id
  end
  Paperclip.interpolates :file_name do |attachment, _|
    attachment.instance.file_file_name
  end

  validates_attachment :avatar,
                       content_type: {content_type: /\Aimage/, message: 'Errors'},
                       size: {in: RORganize::Application.config.attachments_size,
                              message: "is too big, only #{RORganize::Application.config.attachments_size.max / 1024} kB max is allowed."},
                       file_name: {not: /.exe/, message: 'Errors'}

  def self.permit_attributes
    [:file, :tempfile, :original_filename, :content_type, :headers, :form_data, :name]
  end

  def avatar_file_size
    self.file_file_size
  end

  def avatar_file_name
    self.file_file_name
  end

  def avatar_file_path
    self.file_file_path
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
end