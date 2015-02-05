module Rorganize
  module HTMLTesting
    def node(html)
      Nokogiri::HTML::Document.parse(html).root
    end
  end
end

module Rorganize
  module Decorator
    class TestCase < Draper::TestCase
      include Rorganize::HTMLTesting
      include Rorganize::UserGrantPermissions

      include Rails::Dom::Testing::Assertions
      include ActionDispatch::Assertions
      include ActionView::Context
      include ActionView::Helpers

      attr_accessor :output_buffer, :controller

      def initialize(test_case)
        super(test_case)
        @node = nil #should be defined just before calling assert_select
        @routes = Rails.application.routes
        @controller_class = self.class.determine_default_controller_class(self.class.name)
        @controller = @controller_class.new
        @controller.request = ActionController::TestRequest.new
        @controller_name = @controller.controller_name
        @controller.instance_variable_set(:@sessions, {@controller_name.to_sym => {}})
      end

      setup do
        Draper::ViewContext.current = @controller.view_context
        User.stubs(:current).returns(users(:users_001))
        User.any_instance.stubs(:module_enabled?).returns(true)
        User.any_instance.stubs(:avatar).returns(Avatar.new(name: 'avatar', attachable_id:  User.current.id, attachable_type: 'User'))
        sign_in User.current
        drop_all_user_permissions
        @output_buffer = ActiveSupport::SafeBuffer.new ''
        helpers.output_buffer = @output_buffer
      end

      def node(html)
        @node = super(html)
      end

      def document_root_element
        @node #should be defined just before calling assert_select
      end

      class << self
        def determine_default_controller_class(name)
          determine_constant_from_test_name(name) do |constant|
            Class === constant && constant < ActionController::Metal
          end
        end

        def determine_constant_from_test_name(test_name)
          names = test_name.split "::"
          while names.size > 0 do
            name = names.last
            name.sub!(/DecoratorTest$/, "")
            name = name.pluralize
            name = "#{name}Controller"
            names[names.size - 1] = name
            begin
              constant = names.join("::").safe_constantize
              break(constant) if yield(constant)
            ensure
              names.pop
            end
          end
        end
      end
    end
  end
end