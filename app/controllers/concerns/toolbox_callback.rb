module ToolboxCallback

  def toolbox_callback(collection, klazz, project, collection_deletion = nil)
    #Displaying toolbox with GET request
    if !request.post?
      #loading toolbox
      collection_deletion ||= collection
      if params[:delete]
        render partial: "shared/delete_modal", locals: {collection_deletion: collection_deletion}
      else
        render html: view_context.issue_toolbox(collection) #todo change that with a generic call
      end
    elsif params[:delete_ids]
      #Multi delete
      klazz.bulk_delete(params[:delete_ids], project)
      load_collection
      render json: index_json_response
    else
      if User.current.allowed_to?('edit', controller_name, project)
        #Editing with toolbox
        klazz.bulk_edit(params[:ids], value_params, project)
        load_collection
        render json: index_json_response
      else
        render_403
      end
    end
  end

end
