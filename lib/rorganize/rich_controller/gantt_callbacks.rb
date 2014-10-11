module Rorganize
  module RichController
    module GanttCallbacks

      def add_predecessor
        set_predecessor(params[:issue][:predecessor_id])
      end

      def del_predecessor
        set_predecessor(nil)
      end

      def set_predecessor(predecessor_id)
        @issue_decorator = Issue.find(params[:id]).decorate(context: {project: @project})
        result = @issue_decorator.set_predecessor(predecessor_id)
        respond_to do |format|
          format.js do
            respond_to_js action: 'add_predecessor', locals: {journals: History.new(result[:journals]), success: result[:saved]}, response_header: result[:saved] ? :success : :failure, response_content: result[:saved] ? t(:successful_update) : @issue_decorator.errors.full_messages
          end
        end
      end

    end
  end
end
