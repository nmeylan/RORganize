# Author: Nicolas Meylan
# Date: 11 nov. 2012
# Encoding: UTF-8
# File: attachment_remove.rb

class Attachment < ActiveRecord::Base
  include SmartRecords

  has_attached_file :file, {url: '/system/:class/:attachable_type/:attachable_id/:id/:style/:file_name',
                            hash_secret: RORganize::Application.config.secret_attachment_key,
                            styles: {logo: '40x40', thumb: '100x100>', small: '150x150>', medium: '300x300>', large: '800x800>'}}

  Paperclip.interpolates :attachable_type do |attachment, _|
    attachment.instance.attachable_type.pluralize
  end

  Paperclip.interpolates :attachable_id do |attachment, _|
    attachment.instance.attachable_id
  end

  Paperclip.interpolates :file_name do |attachment, _|
    attachment.instance.file_file_name
  end

  before_post_process :should_process?

  validates_attachment :file,
                       content_type: {content_type: /\A(image|application|text)/,
                                      not: %w(application/x-sh application/x-shar),
                                      message: 'has a non allowed content type.'},
                       size: {in: RORganize::Application.config.attachments_size,
                              message: "is too big, only #{RORganize::Application.config.attachments_size.max / 1024} kB max is allowed."},
                       file_name: {not: /.exe/, message: 'has a forbidden filename.'}

  def self.permit_attributes
    [:file, :tempfile, :original_filename, :content_type, :headers, :form_data, :name]
  end


  def self.file_size_error_message

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

  def should_process?
    !file_content_type.match(/\Aimage/).nil?
  end

end