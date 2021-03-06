# Author: Nicolas Meylan
# Date: 09.10.14
# Encoding: UTF-8
# File: issue_statuses_color_manager.rb
module Rorganize
  module Managers
    module IssueStatusesColorManager
      class << self

        def initialize
          load_colors
        end

        def load_colors
          if $0.include?('rake')
            @colors = {}
          else
            @colors = IssuesStatus.statuses_colors
          end
        end

        def colors
          unless @colors
            load_colors
          end
          @colors
        end
      end
    end
  end
end