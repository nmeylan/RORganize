module IssuesHelper
  #Insert updated attributes in journal detail
  def issues_journal_insertion(updated_attrs, journal, journalized_property, foreign_key_value = {})
    #Remove attributes that won't be considarate in journal update
    updated_attrs.each do |attribute, old_new_value|
      if foreign_key_value[attribute]
        if foreign_key_value[attribute].eql?(IssuesStatus)
          old_value = foreign_key_value[attribute].find(old_new_value[0]).enumeration.name
          new_value = foreign_key_value[attribute].find(old_new_value[1]).enumeration.name
        else
          old_value = old_new_value[0] && !foreign_key_value[attribute].nil? ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[0]).first.name : nil
          new_value = old_new_value[1] && !old_new_value[1].eql?('') ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[1]).first.name : ''
        end
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      JournalDetail.create(:journal_id => journal.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end


  def issues_generics_form_to_json
    form_hash = {}
    filter_content_hash = Issue.filter_content_hash(@project)
    hash_for_radio = filter_content_hash['hash_for_radio']
    hash_for_select = filter_content_hash['hash_for_select']
    form_hash['assigned_to'] = generics_filter_simple_select('assigned_to',hash_for_radio['assigned'],hash_for_select['assigned'],true,nil, 'Assigned to')
    form_hash['author'] = generics_filter_simple_select('author',hash_for_radio['author'],hash_for_select['author'], 'Author')
    form_hash['category'] = generics_filter_simple_select('category',hash_for_radio['category'],hash_for_select['category'])
    form_hash['created_at'] = generics_filter_date_field('created_at',hash_for_radio['created'])
    form_hash['done'] = generics_filter_simple_select('done',hash_for_radio['done'],hash_for_select['done'],false, 'cbb-small')
    form_hash['due_date'] = generics_filter_date_field('due_date',hash_for_radio['due_date'], 'Due date')
    form_hash['start_date'] = generics_filter_date_field('start_date',hash_for_radio['start'])
    form_hash['status'] = generics_filter_simple_select('status',hash_for_radio['status'],hash_for_select['status'], 'Status')
    form_hash['subject'] = generics_filter_text_field('subject',hash_for_radio['subject'], 'Subject')
    form_hash['tracker'] = generics_filter_simple_select('tracker',hash_for_radio['tracker'],hash_for_select['tracker'], 'Tracker')
    form_hash['version'] = generics_filter_simple_select('version',hash_for_radio['version'],hash_for_select['version'], 'Version')
    form_hash['updated_at'] = generics_filter_date_field('updated_at',hash_for_radio['updated'], 'Updated')
    form_hash.each{|k,v| v.gsub(/"/,"'").gsub(/\n/, '')}
    return form_hash.to_json
  end

  def issues_activities_text_builder(journal, specified_project = true)
    text = ''
    if journal.action_type.eql?('updated')
      text += "<p class='icon'>"
      if journal.details.empty? && !journal.notes.nil? && !journal.notes.eql?('')
        text += "#{image_tag("<%= asset_path 'activity_comment.png' %>")} #{journal.user.name} #{t(:label_commented_lower_case)} "
      else
        text += "#{image_tag("<%= asset_path 'activity_edit.png' %>")} #{journal.user.name} #{t(:label_updated_lower_case)} "
      end
      text += "<b>#{journal.journalized_type} ##{link_to journal.journalized_id, issue_path(journal.project.slug, journal.journalized_id)}</b>"
      if journal.project_id && specified_project
        text += " #{t(:label_at)} <b>#{link_to journal.project.slug,overview_projects_path(journal.project.slug)}</b>"
      end
      text += '</p>'
    elsif journal.action_type.eql?('created')
      text += "<p class='icon'>"
      text += "#{image_tag("<%= asset_path 'activity_add.png' %>")} #{journal.user.name} #{t(:label_created_lower_case)} "
      text += "<b>#{journal.journalized_type} ##{link_to journal.journalized_id, issue_path(journal.project.slug, journal.journalized_id)}</b>"
      if journal.project_id && specified_project
        text += " #{t(:label_at)} <b>#{link_to journal.project.slug, overview_projects_path(journal.project.slug)}</b>"
      end
      text += '</p>'
    elsif journal.action_type.eql?('deleted')
      text += "<p class='icon'>"
      text += "#{image_tag("<%= asset_path 'activity_deleted.png' %>")} #{journal.user.name} #{t(:label_deleted_lower_case)} "
      text += "<b>#{journal.journalized_type} ##{journal.journalized_id}</b>"
      if journal.project_id && specified_project
        text += " #{t(:label_at)} <b>#{link_to journal.project.slug, overview_projects_path(journal.project.slug)}</b>"
      end
      text += '</p>'
    end
  end
 

end
