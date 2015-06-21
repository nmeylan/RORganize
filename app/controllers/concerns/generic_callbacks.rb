module GenericCallbacks
  def generic_index_callback(locals = {})
    respond_to do |format|
      format.html { render :index, locals: locals }
      format.js { respond_to_js action: 'index', locals: locals }
    end
  end

  def generic_destroy_callback(model, path)
    model.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { js_redirect_to path }
    end
  end

  def generic_show_callback(locals = {})
    respond_to do |format|
      format.html { render :show, locals: locals }
    end
  end

  # @param [ActiveRecord::Base] model
  # @param [Lambda|String] path
  # @param [Hash] locals
  def generic_create_callback(model, path, locals = {})
    respond_to do |format|
      if model.save
        success_generic_create_callback(format, path, true, locals)
      else
        error_generic_create_callback(format, model, locals)
      end
    end
  end

  # @param [ActiveRecord::Base] model
  # @param [Lambda|String] path
  # @param [Hash] locals
  def generic_update_callback(model, path, locals = {})
    respond_to do |format|
      if !model.changed?
        success_generic_update_callback(format, path, false, locals)
      elsif model.changed? && model.save
        success_generic_update_callback(format, path, true, locals)
      else
        error_generic_update_callback(format, model, locals)
      end
    end
  end

  # @param [Format] format
  # @param [Lambda|String] path
  # @param [Boolean] notice display or not the flash notice.
  # @param [Hash] locals
  def success_generic_update_callback(format, path, notice = true, locals = {})
    flash[:notice] = t(:successful_update) if notice
    generic_rediction(format, path)
  end

  def success_generic_create_callback(format, path, notice = true, locals = {})
    flash[:notice] = t(:successful_creation) if notice
    generic_rediction(format, path)
  end

  def error_generic_update_callback(format, model, locals = {})
    generic_error_render(:edit, format, model, locals)
  end

  def error_generic_create_callback(format, model, locals = {})
    generic_error_render(:new, format, model, locals)
  end

  def generic_error_render(action, format, model, locals = {})
    format.html { render action, locals: locals, status: :unprocessable_entity }
    format.json { render json: model.errors, status: :unprocessable_entity }
  end

  def generic_rediction(format, path)
    format.html { redirect_to path }
  end

  # @param [Boolean] success : if the action is a success.
  # @param [Array] messages : array length 2. first index success message, second index error message.
  # @param [Hash] json: a json hash
  def js_callback(success, messages, *json)
    message = success ? messages[0] : messages[1]
    render json: {status: status_response(success, message: message)}.merge(json.extract_options!)
  end

  # @param [Boolean] success : if the action is a success.
  # @param [Symbol] action_type :update / :delete / :create
  # @param [Hash] json: a json hash
  def simple_js_callback(success, action_type, model, *json)
    message = generic_notice_builder(success, action_type, model)
    render json: {status: status_response(success, message: message)}.merge(json.extract_options!)
  end

  def generic_notice_builder(success, action_type, model)
    hash = {update: {failure: "#{t(:failure_update)} : #{model.errors.full_messages.join(', ')}", success: t(:successful_update)},
            create: {failure: "#{t(:failure_creation)} : #{model.errors.full_messages.join(', ')}", success: t(:successful_creation)},
            delete: {failure: t(:failure_deletion), success: t(:successful_deletion)}
    }
    header = success ? :success : :failure
    hash[action_type][header]
  end
end