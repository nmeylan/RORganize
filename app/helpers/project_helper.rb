module ProjectHelper

  def project_archive_permissions(action, controller)
    permissions = Hash.new { |h, k| h[k] = [] }
    permissions['action'] = %w(new edit create update destroy delete checklist change)
    permissions['controller'] = %w(Categories Versions)
    if permissions['controller'].include?(controller)
      return false
    end
    permissions['action'].each do |a|
      if action.include?(a)
        return false
      end
    end
    true
  end

  def activities_ary(issues_activity)
    activity_hash = Hash.new { |h, k| h[k] = [] }
    issues_activity.each do |k, v|
      v.each do |journal|
        user = (journal.user ? journal.user.name : t(:label_unknown))
        item_id = journal.journalized_id
        project_id = journal.project.slug
        activity_hash[k] << content_tag(:li) do
          if journal.action_type.eql?('updated') || journal.action_type.eql?('created')
            safe_concat "#{journal.issue.tracker.name} ##{item_id} "
            safe_concat link_to journal.issue.subject, issue_path(project_id, item_id)
            safe_concat ' '
            if journal.action_type.eql?('updated')
              if journal.details.any?
                safe_concat link_to t(:label_updated_lower_case), load_journal_activity_projects_path(project_id, item_id, k), {:remote => true, :method => :get, :class => 'open_overlay'}
              else
                safe_concat t(:label_updated_lower_case)
              end
            else #Created
              safe_concat content_tag :b, t(:label_created_lower_case)
            end
          elsif journal.action_type.eql?('deleted')
            safe_concat "Issue ##{journal.journalized_id} "
            safe_concat content_tag :b, t(:label_deleted_lower_case)
          end
          safe_concat " #{t(:label_by)} #{user}"
        end
      end
    end
    content_tag :div do
      issues_activity.each do |k, _|
        safe_concat content_tag :h2, k
        safe_concat content_tag :ul, activity_hash[k].uniq.collect { |activity| activity }.join.html_safe
      end
    end
  end

  def project_members(members_hash)
    project_members = ''
    members_hash.each do |role, members|
      members_list = ''
      if members.any?
        members_list += '<ul>'
        members.each do |member|
          members_list += '<li>'+member.user.name+'</li>'
        end
        members_list += '</ul>'
        project_members += role.to_s+': '+members_list
      end
    end
    project_members.html_safe
  end

  def select_tag_versions(id, name, select_key)
    #Don't use hash because, grouped_options will be sort asc : close before open
    option_group_ary = []
    open_ary = []
    open = []
    open << 'Open'
    close_ary = []
    close = []
    close << 'Close'
    versions = @project.versions
    today = Date.current
    select_tag = ''
    versions.each do |version|
      if version.target_date.nil? || (version.target_date && version.target_date > today)
        open_ary << [version.name, version.id, version.target_date]
      else
        close_ary << [version.name, version.id, version.target_date]
      end
    end
    open << open_ary
    close << close_ary
    option_group_ary << open
    option_group_ary << close
    select_tag += "<select class='chzn-select-deselect cbb-medium' tabindex='-1' id='#{id}' name='#{name}'>"
    select_tag += "<option value=''></option>"
    #    select_tag += grouped_options_for_select(option_group_ary, select_key)
    option_group_ary.each do |opt_group|
      select_tag += "<optgroup label='#{opt_group[0].to_s}'>"
      opt_group[1].each do |options|
        select_tag += "<option id='#{options[2]}' value='#{options[1]}' #{'selected="selected"' if options[1].eql?(select_key)}>"+options[0].to_s+'</option>'
      end
      select_tag += '</optgroup>'
    end
    select_tag += '</select>'
  end

  def project_list(projects, allow_to_star)
    content_tag :div, id: 'projects' do
      if  projects && projects.any?
        content_tag :ul, class: "project_list #{allow_to_star ? 'sortable' : '' }" do
          projects.collect do |project|
            last_activity = project.last_activity
            content_tag :li, class: "#{project.is_archived ? 'archived' : ''} project", id: project.id do
              safe_concat project_stats(project).html_safe
              safe_concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
              safe_concat content_tag :p, class: 'project_last_activity', &Proc.new {
                unless last_activity.nil?
                  %Q(#{t(:text_last_activity)} #{distance_of_time_in_words(last_activity.created_at.to_formatted_s, Time.now)} #{t(:label_ago)},
                   #{t(:label_by)} #{last_activity.user ? last_activity.user.name : t(:label_unknown)}.)
                end
              }
              project_list_star_button(project) if allow_to_star
            end
          end.join.html_safe
        end
      else
        t(:text_no_data)
      end
    end
  end

  def project_stats(project)
    content_tag :ul, class: 'project_stats' do
      safe_concat content_tag :li, (content_tag :span, project.members_count, class: 'octicon octicon-organization')
      safe_concat content_tag :li, (content_tag :span, project.issues_count, class: 'octicon octicon-tag')
      safe_concat content_tag :li, (content_tag :span, nil, class: 'octicon octicon-lock') if project.is_archived
    end
  end

  def project_list_star_button(project)
    safe_concat content_tag :div, class: 'star_project', &Proc.new {
      button_tag &Proc.new {
        if project.starred?
          link_to(glyph(t(:link_unstar), 'star'), star_project_my_index_path(project.id), {:class => 'icon icon-fav starred star', :method => :post, :remote => true})
        else
          link_to(glyph(t(:link_star), 'star'), star_project_my_index_path(project.id), {:class => 'icon icon-fav-off star', :method => :post, :remote => true})
        end
      }
    }
  end

end