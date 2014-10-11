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
    end
  end
end
