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
    form_hash['assigned_to'] = generic_filter(:simple_select, 'Assigned to', 'assigned_to', hash_for_radio['assigned'], hash_for_select['assigned'], true, nil)
    form_hash['author'] = generic_filter(:simple_select,  'Author', 'author', hash_for_radio['author'], hash_for_select['author'])
    form_hash['category'] = generic_filter(:simple_select, 'Category', 'category', hash_for_radio['category'], hash_for_select['category'])
    form_hash['created_at'] = generic_filter(:date, 'Created at', 'created_at', hash_for_radio['created'])
    form_hash['done'] = generic_filter(:simple_select, 'Done', 'done', hash_for_radio['done'], hash_for_select['done'], false, 'cbb-small')
    form_hash['due_date'] = generic_filter(:date, 'Due date', 'due_date', hash_for_radio['due_date'])
    form_hash['start_date'] = generic_filter(:date, 'Start date', 'start_date', hash_for_radio['start'])
    form_hash['status'] = generic_filter(:simple_select, 'Status', 'status', hash_for_radio['status'], hash_for_select['status'])
    form_hash['subject'] = generic_filter(:text, 'Subject', 'subject', hash_for_radio['subject'])
    form_hash['tracker'] = generic_filter(:simple_select, 'Tracker', 'tracker', hash_for_radio['tracker'], hash_for_select['tracker'])
    form_hash['version'] = generic_filter(:simple_select, 'Version', 'version', hash_for_radio['version'], hash_for_select['version'])
    form_hash['updated_at'] = generic_filter(:date, 'Updated at', 'updated_at', hash_for_radio['updated'])
    form_hash.each { |k, v| v.gsub(/"/, "'").gsub(/\n/, '') }
    form_hash.to_json
  end

  def issues_activities_text_builder(journal, specified_project = true)
    content_tag :p do
      if journal.action_type.eql?('updated') || journal.action_type.eql?('created')
        if journal.details.empty? && !journal.notes.nil? && !journal.notes.eql?('')
          safe_concat content_tag :span, nil, {class: 'octicon octicon-comment'}
          safe_concat "#{journal.user.name} #{t(:label_commented_lower_case)} "
        else
          safe_concat content_tag :span, nil, {class: 'octicon octicon-pencil'} if journal.action_type.eql?('updated')
          safe_concat content_tag :span, nil, {class: 'octicon octicon-diff-added'} if journal.action_type.eql?('created')
          safe_concat "#{journal.user.name} #{t(:label_updated_lower_case)} "
        end
          safe_concat content_tag :b,"#{journal.journalized_type} "
          safe_concat link_to(journal.journalized_id, issue_path(journal.project.slug, journal.journalized_id))
        if journal.project_id && specified_project
          safe_concat " #{t(:label_at)} "
          safe_concat content_tag :b, link_to(journal.project.slug, overview_projects_path(journal.project.slug))
        end
      elsif journal.action_type.eql?('deleted')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-trashcan'}
        safe_concat "##{journal.user.name} #{t(:label_deleted_lower_case)} "
        safe_concat content_tag :b, "#{journal.journalized_type} ##{journal.journalized_id}"
        if journal.project_id && specified_project
          safe_concat"#{t(:label_at)} "
          safe_concat content_tag :b, link_to(journal.project.slug, overview_projects_path(journal.project.slug))
        end
      end
    end
  end


end
