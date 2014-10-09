# Author: Nicolas Meylan
# Date: 02.10.14
# Encoding: UTF-8
# File: will_paginate_patch.rb

# Reason of this patch :
# Will paginate count method add useless join ("outer") in the count query.
module Rorganize
  module Patches
    module WillPaginatePatch
      module RelationMethods
        def count(*args)
          if limit_value
            excluded = [:order, :limit, :offset, :reorder]
            excluded << :includes unless eager_loading?
            rel = self.except(*excluded)
            joins = rel.values[:joins]
            joins.delete_if{|join| join.downcase.include?('outer')} unless joins.nil? # the patch is here.
            rel = rel.apply_finder_options(@wp_count_options) if defined? @wp_count_options

            column_name = (select_for_count(rel) || :all)
            rel.count(column_name)
          else
            super(*args)
          end
        end
      end
    end
  end
end