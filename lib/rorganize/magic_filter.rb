# Author: Nicolas
# Date: 01/05/2014
# Encoding: UTF-8
# File: ${FILE_NAME}

module Rorganize
  module MagicFilter
    OPERATORS = {'equal' => '<=>',
                 'different' => '<>',
                 'superior' => '>=',
                 'inferior' => '<=',
                 'contains' => 'LIKE',
                 'not_contains' => 'NOT LIKE',
                 'today' => '<=>',
                 'open' => '<=>',
                 'close' => '<=>'}

    NULL_OPERATORS = {'different' => 'IS NOT',
                      'equal' => 'IS'}
    #Specific link between query if there different value for a same attributes: e.g status_id <> 4 AND status_id <> 3
    #but status_id = 4 OR status_id = 3
    LINK_BETWEEN_QUERY = {%w(equal open close) => 'OR',
                          %w(different superior inferior contains not contains) => 'AND'}

    #OPERATORS that are not remove even if value is nil or empty
    OPERATORS_WITHOUT_VALUE = %w(open close today)

    DATE_ATTRIBUTES = %w(created_at updated_at due_date start_date)



    module MultiValuesQueryBuilder
      def build_query_for_values(attributes, hash, inc_condition_item_ary, inc_condition_items, k, link, query_str, v)
        v['value'].each do |value|
          inc_condition_item_ary += 1
          #If it's  the first item from the ary we add (.
          #If it's the last item from the ary we don't put a link(as AND, OR) and we add ).
          #If we use "different" operator we add an OR condition to get items with NULL value.
          #Certains OPERATORS needs specific link.
          operator, value = select_right_operator(v, value)
          query_str += build_left_bracket(inc_condition_item_ary)
          query_str += build_attribute_condition(attributes, k, operator, value)
          query_str += build_condition_link(inc_condition_item_ary, link, v)
          query_str += build_or_statement(attributes, inc_condition_item_ary, k, v, value)
          query_str += build_right_bracket(inc_condition_item_ary, v)
          query_str += build_and_statement(hash, inc_condition_item_ary, inc_condition_items, v)
        end
        query_str
      end

      # Build an end statement if there are another conditions to link with.
      def build_and_statement(hash, inc_condition_item_ary, inc_condition_items, v)
        another_conditions?(hash, inc_condition_item_ary, inc_condition_items, v) ? 'AND '  : ''
      end

      # Do we have to link this condition part with another?
      def another_conditions?(hash, inc_condition_item_ary, inc_condition_items, v)
        inc_condition_item_ary == v['value'].size && inc_condition_items != hash.size
      end

      # Build an or statement if we fetch result with NULL values.
      def build_or_statement(attributes, inc_condition_item_ary, k, v, value)
        fetch_null_values?(inc_condition_item_ary, v, value) ? "#{'OR '+attributes[k].to_s+' IS NULL'} " : ''
      end

      # Do we have to fetch result with NULL values? . We decided to fetch them if we use a "different" operator.
      def fetch_null_values?(inc_condition_item_ary, v, value)
        inc_condition_item_ary == v['value'].size && v['operator'].eql?('different') && !value.eql?('NULL')
      end

      # build the condition part.
      def build_attribute_condition(attributes, k, operator, value)
        "#{attributes[k]} #{operator} #{value} "
      end

      # build a link to another condition (AND, OR) if there others values.
      def build_condition_link(inc_condition_item_ary, link, v)
         inc_condition_item_ary != v['value'].size ? "#{link} " : ''
      end

      # Build left bracket of the query part if it the first iteration.
      def build_left_bracket(inc_condition_item_ary)
        inc_condition_item_ary == 1 ? '(' : ''
      end

      # Build right bracket of the query part if we reach the last value.
      def build_right_bracket(inc_condition_item_ary, v)
        inc_condition_item_ary == v['value'].size ? ') ' : ''
      end

    end

    module SingleValueQueryBuilder
      def build_query_for_date_value(attributes, hash, inc_condition_items, k, v)
        inc_condition_items += 1
        date_value = v['operator'].eql?('today') ? Date.today.to_s : v['value']
        return inc_condition_items, "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{OPERATORS[v['operator']]} '#{date_value}' #{'AND' if inc_condition_items != hash.size} "
      end

      def build_query_for_single_value(attributes, hash, inc_condition_items, k, query_str, v)
        value = v['value'].first
        operator, value = select_right_operator(v, value)
        query_str += build_single_val_attribute_condition(attributes, k, operator, value)
        query_str +=  build_single_val_or_statement(attributes, k, v)
        query_str += build_single_val_and_statement(hash, inc_condition_items)
      end

      def build_single_val_attribute_condition(attributes, k, operator, value)
        "(#{attributes[k]} #{operator} #{value} "
      end

      def build_single_val_or_statement(attributes, k, v)
        "#{'OR '+attributes[k].to_s+' IS NULL' if v['operator'].eql?('different') && !v['value'].first.eql?('NULL')}) "
      end

      def build_single_val_and_statement(hash, inc_condition_items)
        inc_condition_items != hash.size ? 'AND ' : ''
      end
    end

    class << self
      include Rorganize::MagicFilter::MultiValuesQueryBuilder
      include Rorganize::MagicFilter::SingleValueQueryBuilder
      include ActiveRecord::ConnectionAdapters::Quoting

      def generics_filter(hash, attr)
        query_str = ''
        #attributes from db: get real attribute name to build query
        attributes = attr
        hash.delete_if { |_, v| v['operator'].eql?('all') ||(!OPERATORS_WITHOUT_VALUE.include?(v['operator']) && (v['value'].nil? || v['value'].eql?(''))) }

        link = ''
        inc_condition_item_ary = 0 #
        inc_condition_items = 0 #
        query_str = build_query(attributes, hash, inc_condition_item_ary, inc_condition_items, link, query_str)

        query_str += "#{'AND' if hash.size != 0}"
      end

      def build_query(attributes, hash, inc_condition_item_ary, inc_condition_items, link, query_str)
        hash.each do |attribute_name, sub_hash|
          link = get_condition_link(sub_hash, link)
          inc_condition_items, query_str = select_query_builder(attributes, hash, inc_condition_item_ary, inc_condition_items, attribute_name, link, query_str, sub_hash)
          inc_condition_item_ary = 0
        end
        query_str
      end

      def select_query_builder(attributes, hash, inc_condition_item_ary, inc_condition_items, attribute_name, link, query_str, sub_hash)
        if DATE_ATTRIBUTES.include?(attribute_name) #if attribute is a date, apply a specific mysql function to convert a datetime format to date format.
          inc_condition_items, q = build_query_for_date_value(attributes, hash, inc_condition_items, attribute_name, sub_hash)
          query_str += q
        elsif sub_hash['value'].class.eql?(Array) #if values are contains in an ary
          inc_condition_items, query_str = build_query_for_array_value(attributes, hash, inc_condition_item_ary, inc_condition_items, attribute_name, link, query_str, sub_hash)
        else #if attribute has an uniq value
          inc_condition_items, query_str = build_uniq_value_query(attribute_name, attributes, hash, inc_condition_items, query_str, sub_hash)
        end
        return inc_condition_items, query_str
      end

      def build_uniq_value_query(attribute_name, attributes, hash, inc_condition_items, query_str, sub_hash)
        inc_condition_items += 1
        query_str += "#{attributes[attribute_name]} #{OPERATORS[sub_hash['operator']]} \"%#{sub_hash['value']}%\" #{'AND' if inc_condition_items != hash.size} "
        return inc_condition_items, query_str
      end

      def get_condition_link(v, link)
        LINK_BETWEEN_QUERY.each_key { |key| link = LINK_BETWEEN_QUERY[key] if key.include?(v['operator']) }
        link
      end

      def build_query_for_array_value(attributes, hash, inc_condition_item_ary, inc_condition_items, k, link, query_str, v)
        inc_condition_items += 1
        if v['value'].size > 1 #if ary contains more than 1 value
          q = build_query_for_values(attributes, hash, inc_condition_item_ary, inc_condition_items, k, link, query_str, v)
        else #if ary contains less than 2 value
          q = build_query_for_single_value(attributes, hash, inc_condition_items, k, query_str, v)
        end
        return inc_condition_items, q
      end

      def select_right_operator(v, value)
        if value.eql?('NULL')
          operator = NULL_OPERATORS[v['operator']]
        else
          operator = OPERATORS[v['operator']]
          value = quote(value)
        end
        return operator, value
      end
    end


  end
end
