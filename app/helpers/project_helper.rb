module ProjectHelper

  def project_archive_permissions(action, controller)
    permissions = Hash.new{|h,k| h[k] = []}
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
    return true
  end
  def activities_ary(issues_activity)
    activity_hash = Hash.new{|h,k| h[k] = []}
    issues_activity.each do |k,v|
      v.each do |journal|
        user = (journal.user ? journal.user.name : t(:label_unknown))
        #UPDATED
        if journal.action_type.eql?('updated')
          activity_hash[k] << "#{journal.journalized.tracker.name} ##{journal.journalized.id}
                             #{link_to journal.journalized.subject,
          {:action => 'show',
          :controller => 'issues',
          :id => journal.journalized.id} }
                             <b>#{journal.details.any? ? (link_to t(:label_updated_lower_case),
          '#',
          {:class => 'open_overlay',
          :id => journal.journalized.id.to_s+'.'+k.to_s}) : t(:label_updated_lower_case)}</b>
          #{t(:label_by)} #{user}"
          #CREATED
        elsif journal.action_type.eql?('created')
          activity_hash[k] << "#{journal.journalized.tracker.name} ##{journal.journalized.id}
                             #{link_to journal.journalized.subject,
          {:action => 'show',
          :controller => 'issues',
          :id => journal.journalized.id} }
                              <b>#{t(:label_created_lower_case)}</b>
                              #{t(:label_by)} #{user}"
          #DELETED
        elsif journal.action_type.eql?('deleted')
          activity_hash[k] << "Issue ##{journal.journalized_id}
                              <b>#{t(:label_deleted_lower_case)}</b>
                              #{t(:label_by)} #{user}"
        end
      end
    end
    activity_str = ''
    issues_activity.each do |k,v|
      activity_str += "<h2>#{k}</h2>"
      activity_str += '<ul>'
      activity_hash[k].uniq.each{|activity| activity_str += '<li>'+activity+'</li>'
      }
      activity_str += '</ul>'
    end
    return activity_str.html_safe
  end

  def activity_update_link(issue, date)
    link_str = ''
    link_str += "jQuery('#activity_overlay').overlay().load();"
    link_str += "jQuery.ajax({url:'#{url_for(:action => 'load_journal_activity', :controller => 'project',
    :issue_id => issue.id, :activity_date => date)}',
                              type: 'GET',
                              dataType: 'script'});"
    return link_str
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
    return project_members.html_safe
  end

  def select_tag_versions(id,name,select_key)
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
    return select_tag
  end
end
