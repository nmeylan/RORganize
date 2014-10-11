module Rorganize
  module RichController
    module ProjectContext
      def self.included(base)
        base.before_filter { |c| c.menu_context :project_menu }
        base.before_filter { |c| c.menu_item(params[:controller]) }
        base.before_filter { |c| c.top_menu_item('projects') }
      end
    end
  end
end
