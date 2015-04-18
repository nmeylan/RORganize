module Rorganize
  module RichController
    module GanttCallbacks

      # Called in issues controller.
      def add_predecessor
        set_predecessor(params[:issue][:predecessor_id])
      end

      def del_predecessor
        set_predecessor(nil)
      end

      def set_predecessor(predecessor_id)
        @issue_decorator = Issue.find_by(sequence_id: params[:id], project_id: @project.id).decorate(context: {project: @project})
        result = @issue_decorator.set_predecessor(predecessor_id)
        respond_to do |format|
          format.js do
            respond_to_js action: 'add_predecessor', locals: {journals: History.new(result[:journals]), success: result[:saved]},
                          response_header: result[:saved] ? :success : :failure,
                          response_content: result[:saved] ? t(:successful_update) : @issue_decorator.errors.full_messages
          end
        end
      end

      # Called in roadmaps controller.
      def gantt_initialize_sessions
        @sessions[@project.slug] ||= {}
        @sessions[@project.slug][:gantt] ||= {}
        @sessions[@project.slug][:gantt][:edition] ||= false
      end

      def gantt_load_versions
        if @sessions[@project.slug][:gantt][:versions]
          Version.includes(issues: [:parent, :children, :tracker, :assigned_to, :status]).where(id: @sessions[@project.slug][:gantt][:versions])
        else
          @project_decorator.versions.includes(issues: [:parent, :children, :tracker, :assigned_to, :status])
              .where('versions.is_done = ? AND versions.project_id = ?', false, @project.id)
        end
      end

      def gantt
        gantt_initialize_sessions
        if params[:value]
          @sessions[@project.slug][:gantt][:versions] = params[:value]
        end
        if params[:mode]
          @sessions[@project.slug][:gantt][:edition] = params[:mode].eql?('edition')
        end
        prepare_data
        gon.Gantt_JSON = @gantt_object.json_data
        respond_to do |format|
          format.html { render :gantt, locals: {versions: @project_decorator.versions, selected_versions: @versions} }
          format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data, save: false} }
        end
      end

      def manage_gantt
        gantt_initialize_sessions
        if request.post?
          respond_to_save
        else
          respond_to_switch_mode
        end
      end

      def respond_to_switch_mode
        if switched_to_edition?
          respond_to_edition_mode
        else
          gantt
        end
      end

      def respond_to_edition_mode
        @sessions[@project.slug][:gantt][:edition] = true
        prepare_data
        respond_to do |format|
          format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data, save: false} }
        end
      end

      def switched_to_edition?
        params[:mode] && params[:mode].eql?('edition')
      end

      def respond_to_save
        errors = save_gantt(params[:gantt])
        prepare_data
        message = errors && errors.any? ? errors : t(:successful_update)
        header = errors && errors.any? ? :failure : :success
        respond_to do |format|
          format.js { respond_to_js action: 'gantt', response_header: header, response_content: message, locals: {json_data: @gantt_object.json_data, save: true} }
        end
      end

      def prepare_data
        @versions = gantt_load_versions
        @gantt_object = GanttObject.new(@versions, @project_decorator, @sessions[@project.slug][:gantt][:edition])
      end

      def save_gantt(gantt)
        version_changes = {}
        issue_changes = {}
        if gantt[:data]
          get_changed_items(gantt, issue_changes, version_changes)
        end
        if gantt[:links]
          get_changed_links(gantt, issue_changes)
        end
        Version.gantt_edit(version_changes)
        Issue.gantt_edit(issue_changes, @project)
      end

      def get_changed_links(gantt, issue_changes)
        gantt[:links].each do |_, link|
          unless is_item_a_version?(link)
            get_changed_issues_links(issue_changes, link)
          end
        end
      end

      def get_changed_issues_links(issue_changes, link)
        if issue_changes[link[:target]]
          changes = issue_changes[link[:target]].merge({predecessor_id: link[:source], link_type: link[:type]})
        else
          changes = {predecessor_id: link[:source], link_type: link[:type]}
        end
        issue_changes[link[:target]] = changes
      end

      def is_item_a_version?(link)
        link[:source].start_with?('version') || link[:target].start_with?('version')
      end

      def get_changed_items(gantt, issue_changes, version_changes)
        gantt[:data].each do |_, task|
          if task[:id].start_with?('version')
            get_changed_versions(task, version_changes)
          else
            get_changed_issues(issue_changes, task)
          end
        end
      end

      def get_changed_versions(task, version_changes)
        version_changes[task[:id].split('_').last] = {start_date: task[:start_date], target_date: task[:context][:due_date]}
      end

      def get_changed_issues(issue_changes, task)
        issue_changes[task[:id]] = {start_date: task[:start_date], due_date: task[:context][:due_date]}
      end

    end
  end
end
