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
        element = element_type.find_by_id(params[:element_id]) if element_type
        unless element.nil?
          header, message = update_task_list(element)
        end
        respond_to do |format|
          format.js { respond_to_js action: 'do_nothing', response_header: header, response_content: message }
        end
      end

      def update_task_list(element)
        project = Project.find_by_id(element.project_id)
        content, header, message = select_content_to_update(element, project)
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
        if params[:element_type].eql?('Comment')
          element.update_column(:content, content)
        elsif params[:element_type].eql?('Issue') || params[:element_type].eql?('Document')
          element.update_column(:description, content)
        end
      end

      def select_content_to_update(element, project)
        if user_allowed_to_update_in_comment_list?(element, project)
          content = element.content
        elsif user_allowed_to_update_list?(element, project)
          content = element.description
        else #User try to cheat.
          content = nil
          message = "Don't try to brain the master. You now you haven't the permission to perform this action!"
          header = :failure
        end
        return content, header, message
      end

      def user_allowed_to_update_list?(element, project)
        user_allowed_to_update_in_issue_list?(element, project) || user_allowed_to_update_in_document_list?(project)
      end

      def user_allowed_to_update_in_document_list?(project)
        (params[:element_type].eql?('Document') && (User.current.allowed_to?('edit', 'documents', project)))
      end

      def user_allowed_to_update_in_issue_list?(element, project)
        (params[:element_type].eql?('Issue') && (element.author.eql?(User.current) || User.current.allowed_to?('edit_not_owner', 'issues', project)))
      end

      def user_allowed_to_update_in_comment_list?(element, project)
        params[:element_type].eql?('Comment') && (User.current.allowed_to?('edit_comment_not_owner', 'comments', project) || element.user_id.eql?(User.current.id))
      end
    end
  end
end
