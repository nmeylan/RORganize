module Rorganize
  module RichController
    module AttachableCallbacks

      # @param [ActiveRecord::Base] model. can be decorated with draper.
      # @param [Lambda|String] path.
      # @param [Hash] params.
      # @param [Hash] locals.
      def update_attachable_callback(model, path, params, locals = {})
        respond_to do |format|
          if !model_changed?(model, params)
            success_generic_update_callback(format, path, false)
            #If attributes were updated
          elsif model_saved?(model)
            success_generic_update_callback(format, path)
          else
            error_generic_update_callback(format, path, locals)
          end
        end
      end


      def any_attachement_uploaded?(params)
        params[:new_attachment_attributes]
      end

      def model_saved?(model)
        model.save
      end

      def model_changed?(model, params)
        model.changed? || any_attachement_uploaded?(params)
      end

      def delete_attachment
        attachment = Attachment.find(params[:id])
        if attachment.destroy
          respond_to do |format|
            format.js { respond_to_js response_header: :success, response_content: t(:successful_deletion), locals: {id: attachment.id} }
          end
        end
      end

    end
  end
end
