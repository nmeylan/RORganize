module Rorganize
  module RichController
    module TaskListCallback

      def task_list_action_markdown
        element_types = {'Comment' => Comment, 'Issue' => Issue, 'Document' => Document}
        params.require(:is_check)
        params.require(:element_type)
        params.require(:element_id)
        params.require(:check_index)
        element_type = element_types[params[:element_type]]
        element = element_type.find_by_id!(params[:element_id])
        header, message = update_task_list(element)
        respond_to do |format|
          format.js { respond_to_js action: 'do_nothing', response_header: header, response_content: message }
        end
      end

      def update_task_list(element)
        project = Project.find_by_id(element.project_id)
        content = select_content_to_update(element, project)
        unless content.nil?
          header, message = perform_update(content, element)
        end
        return header, message
      end

      def perform_update(content, element)
        count = -1
        content.gsub!(/- \[(\w|\s)\]/) do |task|
          count += 1
          if count == params[:check_index].to_i
            params[:is_check].eql?('true') ? '- [x]' : '- [ ]'
          else
            task
          end
        end
        save_modification(content, element)
        message = t(:successful_update)
        header = :success
        return header, message
      end

      def save_modification(content, element)
        if element.respond_to?(:content)
          element.update_column(:content, content)
        elsif element.respond_to?(:description)
          element.update_column(:description, content)
        end
      end

      def select_content_to_update(element, project)
        if user_allowed_to_update_list?(element, project)
          if element.respond_to?(:content)
            element.content
          elsif element.respond_to?(:description)
            element.description
          end
        else #User try to cheat.
          raise ActionController::RoutingError.new('Forbidden')
        end
      end

      def user_allowed_to_update_list?(element, project)
        (element.respond_to?(:author) && element.author.eql?(User.current)) ||
            User.current.allowed_to?('edit', Rorganize::Utils::class_name_to_controller_name(element.class.to_s), project)
      end
    end
  end
end
