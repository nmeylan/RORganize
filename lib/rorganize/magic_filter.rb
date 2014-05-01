# Author: Nicolas
# Date: 01/05/2014
# Encoding: UTF-8
# File: ${FILE_NAME}

module Rorganize
  module MagicFilter
    #Filter method
    def generics_filter(hash, attr)
      query_str = ''
      #attributes from db: get real attribute name to build query
      attributes = attr
      #noinspection RubyStringKeysInHashInspection,RubyStringKeysInHashInspection
      operators = {'equal' => '<=>', 'different' => '<>', 'superior' => '>=', 'inferior' => '<=', 'contains' => 'LIKE', 'not contains' => 'NOT LIKE', 'today' => '<=>', 'open' => '<=>', 'close' => '<=>'}
      #noinspection RubyStringKeysInHashInspection
      null_operators = {'different' => 'IS NOT', 'equal' => 'IS'}
      #Specific link between query if there different value for a same attributes: e.g status_id <> 4 AND status_id <> 3
      #but status_id = 4 OR status_id = 3
      link_between_query = {%w(equal open close) => 'OR', ['different', 'superior', 'inferior', 'contains', 'not contains'] => 'AND'}

      #operators that are not remove even if value is nil or empty
      operators_without_value = %w(open close today)
      hash.delete_if { |k, v| v['operator'].eql?('all') ||(!operators_without_value.include?(v['operator']) && (v['value'].nil? || v['value'].eql?(''))) }

      date_attributes = %w(created_at updated_at due_date start_date)
      link = ''
      inc_condition_item_ary = 0 #
      inc_condition_items = 0 #
      hash.each do |k, v|
        link_between_query.each_key { |key| link = link_between_query[key] if key.include?(v['operator']) }
        if date_attributes.include?(k) #if attribute is a date, apply a specific mysql function to convert a datetime format to date format.
          inc_condition_items += 1
          if v['operator'].eql?('today') #if user use "today" radio button we use the current date.
            # Add an "AND" at the end of the string if there any other conditions for the query
            query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v['operator']]} '#{Date.today.to_s}' #{'AND' if inc_condition_items != hash.size} "
          else
            # Add an "AND" at the end of the string if there any other conditions for the query
            query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v['operator']]} '#{v['value']}' #{'AND' if inc_condition_items != hash.size} "
          end
        elsif v['value'].class.eql?(Array) #if values are contains in an ary
          if v['value'].size > 1 #if ary contains more than 1 value
            inc_condition_items += 1
            v['value'].each do |value|
              inc_condition_item_ary += 1
              #If it's  the first item from the ary we add (.
              #If it's the last item from the ary we don't put a link and we add ).
              #If we use "different" operator we add an OR condition to get items which value is NULL.
              #Certains operators needs specific link.
              if value.eql?('NULL')
                operator = null_operators[v['operator']]
              else
                operator = operators[v['operator']]
              end
              query_str += "#{'(' if inc_condition_item_ary == 1}"
              query_str += "#{attributes[k]} #{operator} #{value} "
              query_str += "#{link if inc_condition_item_ary != v['value'].size} "
              query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if inc_condition_item_ary == v['value'].size && v['operator'].eql?('different') && !value.eql?('NULL')}"
              query_str += "#{')' if inc_condition_item_ary == v['value'].size} "
              query_str += "#{'AND' if inc_condition_item_ary == v['value'].size && inc_condition_items != hash.size} "
            end
          else #if ary contains less than 1 value
            if v['value'].first.eql?('NULL')
              operator = null_operators[v['operator']]
            else
              operator = operators[v['operator']]
            end
            inc_condition_items += 1
            query_str += "(#{attributes[k]} #{operator} #{v['value'].first} "
            query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if v['operator'].eql?('different') && !v['value'].first.eql?('NULL')}) "
            query_str += "#{'AND' if inc_condition_items != hash.size} "
          end
        else #if attribute has an uniq value
          inc_condition_items += 1
          query_str += "#{attributes[k]} #{operators[v['operator']]} '%#{v['value']}%' #{'AND' if inc_condition_items != hash.size} "
        end
        inc_condition_item_ary = 0
      end
      #    query_str += "#{'AND' if hash.size != 0} issues.project_id = #{project_id}"
      query_str += "#{'AND' if hash.size != 0}"
      return query_str
    end

  end
end
