# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_extra_methods.rb
module Rorganize
  module Models
    module IssueExtraMethods
      def self.included(base)
        base.extend(Issues::IssueGantt::ClassMethods)
        base.extend(Issues::IssueDatesValidator::ClassMethods)
      end
      include Issues::IssueGantt
      include Issues::IssueDatesValidator

    end
  end
end