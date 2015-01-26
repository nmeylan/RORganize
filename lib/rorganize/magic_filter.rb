# Author: Nicolas
# Date: 01/05/2014
# Encoding: UTF-8
# File: ${FILE_NAME}

module Rorganize
  module MagicFilter
    def self.is_mysql?
      ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
    end

    def self.is_sqlite?
      ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')
    end

    if is_mysql?
      OPERATORS = {'equal' => '<=>',
                   'different' => '<>',
                   'superior' => '>=',
                   'inferior' => '<=',
                   'contains' => 'LIKE',
                   'not_contains' => 'NOT LIKE',
                   'today' => '<=>',
                   'open' => '<=>',
                   'close' => '<=>'}
    elsif is_sqlite?
      OPERATORS = {'equal' => 'IS',
                   'different' => '<>',
                   'superior' => '>=',
                   'inferior' => '<=',
                   'contains' => 'LIKE',
                   'not_contains' => 'NOT LIKE',
                   'today' => 'IS',
                   'open' => 'IS',
                   'close' => 'IS'}
    end

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
      # This select the appropriate way to build a condition clause.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] link : the link between condition clause ('OR' or 'AND').
      # @param [String] query_str : the built query string.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def build_query_for_values(attributes, number_criteria, sub_condition_clauses_counter, condition_clauses_counter,
                                 attribute_name, link, query_str, operator_value_hash)
        sub_clause_number_values = operator_value_hash['value'].size
        operator_value_hash['value'].each do |value|
          sub_condition_clauses_counter += 1
          #If it's  the first item from the ary we add (.
          #If it's the last item from the ary we don't put a link(as AND, OR) and we add ).
          #If we use "different" operator we add an OR condition to get items with NULL value.
          #Certains OPERATORS needs specific link.
          operator, value = select_right_operator(operator_value_hash, value)
          query_str += build_left_bracket(sub_condition_clauses_counter)
          query_str += build_attribute_condition(attributes, attribute_name, operator, value)
          query_str += build_condition_link(sub_condition_clauses_counter, link, sub_clause_number_values)
          query_str += build_or_statement(attributes, sub_condition_clauses_counter, attribute_name, operator_value_hash, value)
          query_str += build_right_bracket(sub_condition_clauses_counter, sub_clause_number_values)
          query_str += build_and_statement(number_criteria, sub_condition_clauses_counter, condition_clauses_counter, sub_clause_number_values)
        end
        query_str
      end

      # Build an end statement if there are another conditions to link with.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # @param [Numeric] sub_clause_number_values : number of values of the sub condition_clause.
      def build_and_statement(number_criteria, sub_condition_clauses_counter, condition_clauses_counter, sub_clause_number_values)
        another_conditions?(number_criteria, sub_condition_clauses_counter, condition_clauses_counter, sub_clause_number_values) ? 'AND ' : ''
      end

      # Do we have to link this condition part with another?
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [Numeric] sub_clause_number_values : number of values of the sub condition_clause.
      def another_conditions?(number_criteria, sub_condition_clauses_counter, condition_clauses_counter, sub_clause_number_values)
        sub_condition_clauses_counter == sub_clause_number_values && condition_clauses_counter != number_criteria
      end

      # Build an or statement if we fetch result with NULL values.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      # @param [String] value : the sub clause value.
      def build_or_statement(attributes, sub_condition_clauses_counter, attribute_name, operator_value_hash, value)
        fetch_null_values?(sub_condition_clauses_counter, operator_value_hash, value) ? "#{'OR '+attributes[attribute_name].to_s+' IS NULL'} " : ''
      end

      # Do we have to fetch result with NULL values? . We decided to fetch them if we use a "different" operator.
      def fetch_null_values?(sub_condition_clauses_counter, operator_value_hash, value)
        sub_condition_clauses_counter == operator_value_hash['value'].size && operator_value_hash['operator'].eql?('different') && !value.eql?('NULL')
      end

      # build the condition part.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] operator : the sub clause operator.
      # @param [String] value : the sub clause value.
      def build_attribute_condition(attributes, attribute_name, operator, value)
        "#{attributes[attribute_name]} #{operator} #{value} "
      end

      # build a link to another condition (AND, OR) if there others values.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [String] link : the link between condition clause ('OR' or 'AND').
      # @param [Numeric] sub_clause_number_values : number of values of the sub condition_clause.
      def build_condition_link(sub_condition_clauses_counter, link, sub_clause_number_values)
        sub_condition_clauses_counter != sub_clause_number_values ? "#{link} " : ''
      end

      # Build left bracket of the query part if it the first iteration.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      def build_left_bracket(sub_condition_clauses_counter)
        sub_condition_clauses_counter == 1 ? '(' : ''
      end

      # Build right bracket of the query part if we reach the last value.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] sub_clause_number_values : number of values of the sub condition_clause.
      def build_right_bracket(sub_condition_clauses_counter, sub_clause_number_values)
        sub_condition_clauses_counter == sub_clause_number_values ? ') ' : ''
      end

    end

    module SingleValueQueryBuilder
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def build_query_for_date_value(attributes, number_criteria, condition_clauses_counter, attribute_name, operator_value_hash)
        condition_clauses_counter += 1
        date_value = operator_value_hash['operator'].eql?('today') ? Date.today.to_s : operator_value_hash['value']
        query_str = date_format_adapter(attribute_name, attributes, date_value, operator_value_hash)

        query_str += 'AND ' if condition_clauses_counter != number_criteria
        return condition_clauses_counter, query_str
      end

      def date_format_adapter(attribute_name, attributes, date_value, operator_value_hash)
        if is_mysql?
          query_str = "DATE_FORMAT(#{attributes[attribute_name]},'%Y-%m-%d') #{OPERATORS[operator_value_hash['operator']]} '#{date_value}' "
        else
          query_str = "strftime('%Y-%m-%d', #{attributes[attribute_name]}) #{OPERATORS[operator_value_hash['operator']]} '#{date_value}' "
        end
      end

      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] query_str : the built query string.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def build_query_for_single_value(attributes, number_criteria, condition_clauses_counter, attribute_name, query_str, operator_value_hash)
        value = operator_value_hash['value'].first
        operator, value = select_right_operator(operator_value_hash, value)
        query_str += build_single_val_attribute_condition(attributes, attribute_name, operator, value)
        query_str += build_single_val_or_statement(attributes, attribute_name, operator_value_hash)
        query_str += build_single_val_and_statement(number_criteria, condition_clauses_counter)
      end

      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] operator : the clause operator.
      # @param [String] value : the clause value.
      def build_single_val_attribute_condition(attributes, attribute_name, operator, value)
        "(#{attributes[attribute_name]} #{operator} #{value} "
      end

      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [Hash] operator_value_hash : a hash with the following structure.
      def build_single_val_or_statement(attributes, attribute_name, operator_value_hash)
        "#{'OR '+attributes[attribute_name].to_s+' IS NULL' if operator_value_hash['operator'].eql?('different') && !operator_value_hash['value'].first.eql?('NULL')}) "
      end

      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      def build_single_val_and_statement(number_criteria, condition_clauses_counter)
        condition_clauses_counter != number_criteria ? 'AND ' : ''
      end
    end

    class << self
      include Rorganize::MagicFilter::MultiValuesQueryBuilder
      include Rorganize::MagicFilter::SingleValueQueryBuilder
      include ActiveRecord::ConnectionAdapters::Quoting
      #@param [Hash] criteria_hash : a criteria_hash with the following structure
      # {'attribute_name':String => {"operator"=> String, "value"=> String}}
      # 'attribute_name' is the name of the attribute on which criterion is based
      # E.g : {"subject"=>{"operator"=>"contains", "value"=>"test"}}
      # operator values are :
      # 'equal'
      # 'different'
      # 'superior'
      # 'inferior'
      # 'contains'
      # 'not_contains'
      # 'today'
      # 'open'
      # 'close'
      # @param [Hash] attr : a criteria_hash with following structure
      # this make a link between attribute name an the correspondent field in database.
      # {'attribute_name':String => table_name.database_field}
      def generics_filter(criteria_hash, attr)
        query_str = ''
        #attributes from db: get real attribute name to build query
        attributes = attr
        criteria_hash.delete_if { |_, v| v['operator'].eql?('all') ||(!OPERATORS_WITHOUT_VALUE.include?(v['operator']) && (v['value'].nil? || v['value'].eql?(''))) }

        sub_condition_clauses_counter = 0 #
        condition_clauses_counter = 0 #
        query_str = build_query(attributes, criteria_hash, sub_condition_clauses_counter, condition_clauses_counter, query_str)

        query_str += "#{'AND' if criteria_hash.size != 0}"
      end

      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Hash] criteria_hash : the criteria_hash that containing criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] query_str : the built query string.
      def build_query(attributes, criteria_hash, sub_condition_clauses_counter, condition_clauses_counter, query_str)
        criteria_hash.each do |attribute_name, operator_value_hash|
          link = get_condition_link(operator_value_hash)
          condition_clauses_counter, query_str = select_query_builder(attributes,
                                                                      criteria_hash.size,
                                                                      sub_condition_clauses_counter,
                                                                      condition_clauses_counter,
                                                                      attribute_name,
                                                                      link,
                                                                      query_str,
                                                                      operator_value_hash)
          sub_condition_clauses_counter = 0
        end
        query_str
      end

      # This select the appropriate way to build a condition clause.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] link : the link between condition clause ('OR' or 'AND').
      # @param [String] query_str : the built query string.
      # @param [Hash] operator_value_hash : a criteria_hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def select_query_builder(attributes, number_criteria, sub_condition_clauses_counter, condition_clauses_counter, attribute_name, link, query_str, operator_value_hash)
        if DATE_ATTRIBUTES.include?(attribute_name) #if attribute is a date, apply a specific mysql function to convert a datetime format to date format.
          condition_clauses_counter, q = build_query_for_date_value(attributes,
                                                                    number_criteria,
                                                                    condition_clauses_counter,
                                                                    attribute_name,
                                                                    operator_value_hash)
          query_str += q
        elsif operator_value_hash['value'].class.eql?(Array) #if values are contains in an ary
          condition_clauses_counter, query_str = build_query_for_array_value(attributes,
                                                                             number_criteria,
                                                                             sub_condition_clauses_counter,
                                                                             condition_clauses_counter,
                                                                             attribute_name,
                                                                             link,
                                                                             query_str,
                                                                             operator_value_hash)
        else #if attribute has an uniq value
          condition_clauses_counter, query_str = build_uniq_value_query(attribute_name,
                                                                        attributes,
                                                                        number_criteria,
                                                                        condition_clauses_counter,
                                                                        query_str,
                                                                        operator_value_hash)
        end
        return condition_clauses_counter, query_str
      end


      # This build a condition clause for a uniq value for a given attribute.
      # E.g : {'name' => {'operator' => 'contains', 'value' => 'hello'}}
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] query_str : the built query string.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def build_uniq_value_query(attribute_name, attributes, number_criteria, condition_clauses_counter, query_str, operator_value_hash)
        condition_clauses_counter += 1
        query_str += "#{attributes[attribute_name]} #{OPERATORS[operator_value_hash['operator']]} \"%#{operator_value_hash['value']}%\" "
        query_str += 'AND ' if condition_clauses_counter != number_criteria
        return condition_clauses_counter, query_str
      end

      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      # @return [String] return 'OR' or 'AND'.
      def get_condition_link(operator_value_hash)
        link = ''
        LINK_BETWEEN_QUERY.each_key { |key| link = LINK_BETWEEN_QUERY[key] if key.include?(operator_value_hash['operator']) }
        link
      end

      # This select the appropriate way to build a condition clause.
      # @param [Hash] attributes : the attribute / database field criteria_hash.
      # @param [Numeric] number_criteria : the total number of criteria.
      # @param [Numeric] sub_condition_clauses_counter : this counter is incremented
      # each time that a sub condition clause is add into a same condition clause.
      # @param [Numeric] condition_clauses_counter : this counter is incremented
      # each time that a condition clause is add to the condition string.
      # Note : counter are used to close parenthesis.
      # @param [String] attribute_name : the name of the attribute that is used in the condition clause.
      # @param [String] link : the link between condition clause ('OR' or 'AND').
      # @param [String] query_str : the built query string.
      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      def build_query_for_array_value(attributes, number_criteria, sub_condition_clauses_counter, condition_clauses_counter,
                                      attribute_name, link, query_str, operator_value_hash)
        condition_clauses_counter += 1
        if operator_value_hash['value'].size > 1 #if ary contains more than 1 value
          q = build_query_for_values(attributes,
                                     number_criteria,
                                     sub_condition_clauses_counter,
                                     condition_clauses_counter,
                                     attribute_name,
                                     link,
                                     query_str,
                                     operator_value_hash)
        else #if ary contains less than 2 value
          q = build_query_for_single_value(attributes,
                                           number_criteria,
                                           condition_clauses_counter,
                                           attribute_name,
                                           query_str,
                                           operator_value_hash)
        end
        return condition_clauses_counter, q
      end

      # @param [Hash] operator_value_hash : a hash with the following structure :
      # {"operator"=> String, "value"=> String}}
      # E.g : {"operator"=>"contains", "value"=>"test"}
      # @param [String] value : the criterion value.
      def select_right_operator(operator_value_hash, value)
        if value.eql?('NULL')
          operator = NULL_OPERATORS[operator_value_hash['operator']]
        else
          operator = OPERATORS[operator_value_hash['operator']]
          value = quote(value)
        end
        return operator, value
      end
    end


  end
end
