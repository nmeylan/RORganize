# Author: Nicolas Meylan
# Date: 23.01.15 11:45
# Encoding: UTF-8
# File: generic_test_cases.rb
module Rorganize
  module GenericControllersTestCases

    def should_get_404_on(method, action, *args)
      send(method, action, *args)
      assert_response :missing
      if format_js?(*args)
        assert_not_nil @response.header["flash-error-message"]
        assert @response.header["flash-error-message"].start_with?('Seems')
      else
       assert_select "title", "The page you were looking for doesn't exist (404)"
      end
    end

    def format_js?(*args)
      args = [{}] if args.first.nil?
      hash = args.first
      hash[:format] && hash[:format].eql?(:js)
    end
  end
end