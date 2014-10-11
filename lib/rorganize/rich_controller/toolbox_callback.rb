module Rorganize
  module RichController
    module ToolboxCallback

      def toolbox_callback(collection, klazz, project)
        #Displaying toolbox with GET request
        if !request.post?
          #loading toolbox

          respond_to do |format|
            format.js { respond_to_js locals: {collection: collection} }
          end
        elsif params[:delete_ids]
          #Multi delete
          klazz.bulk_delete(params[:delete_ids], project)
          load_collection
          respond_to do |format|
            format.js { respond_to_js action: :index, response_header: :success, response_content: t(:successful_deletion) }
          end
        else
          if User.current.allowed_to?('edit', controller_name, project)
            #Editing with toolbox
            klazz.bulk_edit(params[:ids], value_params, project)
            load_collection
            respond_to do |format|
              format.js { respond_to_js action: :index, response_header: :success, response_content: t(:successful_update) }
            end
          else
            render_403
          end
        end
      end

      private

    end
  end
end
