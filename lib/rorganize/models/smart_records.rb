# Author: Nicolas
# Date: 03/05/2014
# Encoding: UTF-8
# File: smart_records.rb
module Rorganize
  module Models
    module SmartRecords
      include Rorganize::Models::AbstractModelCaption

      extend ActiveSupport::Concern
      included do
        scope :paginated, ->(page, per_page, order, includes = []) { paginate(page: page, per_page: per_page).smart_record_order(order, includes) }
        scope :smart_record_order, -> (order, includes) do
          if includes.any?
            dependent_attributes, attr, joins = Rorganize::Models::SmartRecords.smart_records_eager_load(self, includes, order)
            joins(joins).preload(attr).order(order).includes(dependent_attributes)
          else
            order(order)
          end
        end
        scope :filter, ->(filter, project_id) { where("#{filter} #{self.table_name}.project_id = #{project_id}") }
        self.extend(ClassMethods)
      end



      #Change a record's position from a collection. E.g: change_position([a, b, c, d], c, inc)
      # => c position change from 3 to 4 and d position change from 4 to 3, collection order is [a, b, d, c]
      #Available operator are : inc or dec
      # @param [Array] records_collection : an array of ActiveRecord::Base object.
      # @param [ActiveRecord::Base] record : the object whose position changed.
      # @param [String] operator : is 'inc' of 'dec' to increment or decrement the record position.
      def apply_change_position(records_collection, record, operator)
        max = records_collection.size
        saved = false
        position = record.position
        if out_of_bounds?(max, operator, record)
        elsif %w(inc dec).include? operator
          select_operator(operator, position, record, records_collection)
          saved = true
        end
        saved
      end

      def select_operator(operator, position, record, records_collection)
        if operator.eql?('inc')
          change_position!(position, record, records_collection, position + 1)
        else
          change_position!(position, record, records_collection, position - 1)
        end
      end

      def change_position!(position, record, records_collection, new_position)
        o_record = records_collection.detect { |r| r.position.eql?(new_position) }
        o_record.update_column(:position, position)
        record.update_column(:position, new_position)
      end

      def out_of_bounds?(max, operator, record)
        record.position == 1 && operator.eql?('dec') || record.position == max && operator.eql?('inc')
      end


      module ClassMethods
        def attributes_formalized_names
          self.attribute_names.map { |attribute| attribute.gsub('_id', '').gsub('id', '').tr('_', ' ').capitalize unless attribute.eql?('id') }.compact
        end

        def foreign_keys
          self.reflect_on_all_associations(:belongs_to).inject({}) do |memo, association|
            memo[association.foreign_key.to_sym] = association.klass
            memo
          end
        end
      end

      class << self
        # This methods will split the eager lod strategy in two part :
        # 1. if eager_loaded attribute is not the ordered one, we will passed it in the "includes" method.
        # 2. the ordered attribute will be passed in the "joins" method.
        # @param [Class] klazz : the class that calls the scope.
        # @param [Array] includes : an array of all eager_loaded attributes ("includes").
        # @param [String] order : the sql order : e.g(versions.name ASC).
        # @return [Array] array that contains :
        # at index 0 : the list of eager_loaded attribute with the "includes" method.
        # at index 1 : the ordered attribute that will be use in "preload" method.
        # at index 2 : the joins query part.
        def smart_records_eager_load(klazz, includes, order)
          table_name = order.split('.')[0]
          attr = nil
          joins = ''
          unless table_name.eql?(klazz.table_name)
            klazz.reflect_on_all_associations(:belongs_to).each do |attrib|
              if attrib.table_name.eql?(table_name)
                attr = attrib.name.to_sym
                joins = "LEFT OUTER JOIN #{table_name} ON #{table_name}.id = #{klazz.table_name}.#{attrib.foreign_key}"
              end
            end
          end
          [includes.delete_if { |attribute_name| attribute_name.eql?(attr) }, attr, joins]
        end
      end

    end
  end
end