module Rorganize
  module RichController
    module GenericCallbacks

      def generic_destroy_callback(model, path)
        model.destroy
        flash[:notice] = t(:successful_deletion)
        respond_to do |format|
          format.html { redirect_to path }
          format.js { js_redirect_to path }
        end
      end

      def generic_show_callback(decorator)
        respond_to do |format|
          format.html { render :show, locals: {history: History.new(Journal.issue_activities(decorator.id), decorator.comments)} }
        end
      end

      def generic_create(model, path)
        respond_to do |format|
          if model.save
            success_generic_create_callback(format, path)
          else
            error_generic_create_callback(format, model)
          end
        end
      end

      def generic_update(model, path)
        respond_to do |format|
          if !model.changed?
            success_generic_update_callback(format, path, false)
          elsif model.changed? && model.save
            success_generic_update_callback(format, path)
          else
            error_generic_update_callback(format, model)
          end
        end
      end

      def success_generic_update_callback(format, path, notice = true)
        flash[:notice] = t(:successful_creation) if notice
        generic_rediction(format, path)
      end

      def success_generic_create_callback(format, path, notice = true)
        flash[:notice] = t(:successful_update) if notice
        generic_rediction(format, path)
      end

      def error_generic_update_callback(format, model, locals = {})
        generic_error_render(:edit, format, model, locals)
      end

      def error_generic_create_callback(format, model, locals = {})
        generic_error_render(:new, format, model, locals)
      end

      def generic_error_render(action, format, model, locals = {})
        format.html { render action, locals: locals }
        format.json { render json: model.errors, status: :unprocessable_entity }
      end

      def generic_rediction(format, path)
        format.html { redirect_to path }
      end

      # @param [Boolean] success : if the action is a success.
      # @param [Array] messages : array length 2. first index success message, second index error message.
      def js_callback(success, messages, action = nil)
        header = success ? :success : :failure
        message = success ? messages[0] : messages[1]
        action ||= 'do_nothing' unless success
        respond_to do |format|
          format.js { respond_to_js action: action , response_header: header, response_content: message }
        end
      end
        # @param [Boolean] success : if the action is a success.
        # @param [Symbol] action_type :update / :delete / :create
      def simple_js_callback(success, action_type, locals = {})
        header, message = generic_notice_builder(success, action_type)
        do_nothing_action = success ? nil : 'do_nothing'
        respond_to do |format|
          format.js { respond_to_js action: do_nothing_action, response_header: header, response_content: message, locals: locals }
        end
      end

      def generic_notice_builder(success, action_type)
        hash = {update: {failure: t(:failure_update), success: t(:successful_update)},
                create: {failure: t(:failure_creation), success: t(:successful_creation)},
                delete: {failure: t(:failure_deletion), success: t(:successful_deletion)}
        }
        header = success ? :success : :failure
        return header, hash[action_type][header]
      end
    end
  end
end
