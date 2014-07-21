# Author: Nicolas
# Date: 03/05/2014
# Encoding: UTF-8
# File: smart_records.rb
module Rorganize
  module SmartRecords
    include Rorganize::AbstractModelCaption

    extend ActiveSupport::Concern
    included do
      scope :paginated, ->(page, per_page, order) { paginate(:page => page, :per_page => per_page).order(order) }
      scope :filter, ->(filter, project_id) { where("#{filter} #{self.table_name}.project_id = #{project_id}") }
    end
    #Change a record's position from a collection. E.g: change_position([a, b, c, d], c, inc)
    # => c position change from 3 to 4 and d position change from 4 to 3, collection order is [a, b, d, c]
    #Available operator are : inc or dec
    def apply_change_position(records_collection, record, operator)
      max = records_collection.size
      saved = false
      position = record.position
      if record.position == 1 && operator.eql?('dec') ||
          record.position == max && operator.eql?('inc')
      elsif %w(inc dec).include? operator
        if operator.eql?('inc')
          o_record = records_collection.select { |r| r.position.eql?(position + 1) }.first
          o_record.update_column(:position, position)
          record.update_column(:position, position + 1)
        else
          o_record = records_collection.select { |r| r.position.eql?(position - 1) }.first
          o_record.update_column(:position, position)
          record.update_column(:position, position - 1)
        end
        saved = true
      end
      saved
    end


    #ATTACHMENT METHODS
    def new_attachment_attributes=(attachment_attributes)
      attachment_attributes.each do |attributes|
        attributes['object_type'] = self.class.to_s
        attachments.build(attributes)
      end
    end

    def existing_attachment_attributes=(attachment_attributes)
      attachments.reject(&:new_record?).each do |attachment|
        attributes = attachment_attributes[attachment.id.to_s]
        if attributes
          attachment.attributes = attributes
        else
          attachment.delete
        end
      end
    end

    def save_attachments
      attachments.each do |attachment|
        attachment.save(:validation => false)
      end
    end
  end
end