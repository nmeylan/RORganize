module Rorganize
  module Helpers
    class TestCase < ActionView::TestCase
      include Rorganize::HTMLTesting

      setup do
        @av = ActionView::Base.new
        @view_flow = ActionView::OutputFlow.new
        User.stubs(:current).returns(users(:users_001))
      end

      def node(html)
        @node = super(html)
      end


      def document_root_element
        @node #should be defined just before calling assert_select
      end
    end
  end
end