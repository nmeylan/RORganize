module Rorganize
  module RichController
    module AttachmentRemove

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
