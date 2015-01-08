# Author: Nicolas Meylan
# Date: 08.01.15
# Encoding: UTF-8
# File: test_assertions.rb
require_relative 'match_array'
module Rorganize
  module TestAssertions
    def assert_match_array(expected, actual)
      result, message = MatchArray.new(expected, actual).match
      assert result, message
    end
  end
end