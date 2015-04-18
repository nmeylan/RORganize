# Author: Nicolas Meylan
# Date: 21/06/2014
# Encoding: UTF-8
# File: rich_controller.rb
# This allow controller to provide more actions as : bulk_edition or filters

module RichController
  include Pagination
  include GenericCallbacks

  def self.included(base)
    base.before_action :set_pagination, only: [:index]
  end

  def load_paginated_collection(klazz, default_order)
    klazz.prepare_paginated(@sessions[:current_page], @sessions[:per_page], order(default_order), gon_filter_initialize, @project.id).decorate(context: {project: @project, query: @query})
  end

end