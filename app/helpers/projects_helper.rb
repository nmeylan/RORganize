module ProjectsHelper

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

  def display_activities(activities)
    content_tag :div, class: 'activities', &Proc.new {
      activities.each do |date, item|
        safe_concat activities_date(date)
        journals_render(item.compact.sort { |x, y| y.at(0).created_at <=> x.at(0).created_at })
        safe_concat clear_both
      end
    }
  end

  def activities_date(date)
    content_tag :div, class: 'date_circle', &Proc.new {
      content_tag :div, date, class: 'inner_circle'
    }
  end

  #Render all journals
  def journals_render(journals)
    i = 0
    journals.each do |journal|
      safe_concat one_journal_render(journal, journal.at(0), i)
      i += 1
    end
  end

  #Render one journal for same journalized items. if two or more journals exists for one item the same day, they will be compact into one.
  def one_journal_render(journals, journal, nth)
    content_tag :div, class: "activity #{nth % 2 == 0 ? 'odd' : 'even'}", &Proc.new {
      content_tag :p do
        journal_content_render(journal, nth)
        journal_detail_render(journals)
      end
    }
  end

  #Render journal content
  def journal_content_render(journal, nth)
    user = (journal.user ? journal.user.caption : t(:label_unknown))
    if nth % 2 == 0
      safe_concat content_tag :span, nil, class: "#{journal_action_type_icon(journal.action_type)}"
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal_action_type(journal.action_type), class: 'action_type'
      safe_concat content_tag :span, journal_object_type(journal), class: 'object_type'
      safe_concat content_tag :span, journal.created_at.strftime("%I:%M%p"), class: 'date'
    else
      safe_concat content_tag :span, journal.created_at.strftime("%I:%M%p"), class: 'date'
      safe_concat content_tag :span, nil, class: "#{journal_action_type_icon(journal.action_type)}"
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal_action_type(journal.action_type), class: 'action_type'
      safe_concat content_tag :span, journal_object_type(journal), class: 'object_type'
    end
  end

  def journal_detail_render(journals)
    first_journal = journals.at(0)
    safe_concat content_tag :div, class: 'journal_details', &Proc.new {
      safe_concat content_tag :span, link_to(t(:link_new_comment), '#'), class: 'detail comment octicon octicon-comment' unless first_journal.notes.empty?
      safe_concat content_tag(:ul, (first_journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
    }
    journals.delete_at(0)
    if journals.size > 0
      safe_concat link_to 'view more', '#', {class: 'toggle', id: "#{first_journal.journalized_id}_#{first_journal.created_at}"}
      safe_concat content_tag :div, class: 'journal_details hide more', &Proc.new {
        journals.each do |journal|
          if journal.details.to_a.any?
            safe_concat content_tag :div, class: 'detail more', &Proc.new {
              safe_concat content_tag :span, link_to(t(:link_new_comment), '#'), class: 'detail comment octicon octicon-comment' unless journal.notes.empty?
              safe_concat content_tag :span, journal.created_at.strftime("%I:%M%p"), class: 'date'
              safe_concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
            }
          end
        end
      }
    end
  end

  #Give journal action type
  def journal_action_type(action_type)
    if action_type.eql?(Journal::ACTION_CREATE)
      t(:label_created_lower_case)
    elsif action_type.eql?(Journal::ACTION_UPDATE)
      t(:label_updated_lower_case)
    elsif action_type.eql?(Journal::ACTION_DELETE)
      t(:label_deleted_lower_case)
    end
  end

  def journal_action_type_icon(action_type)
    if action_type.eql?(Journal::ACTION_CREATE)
      'octicon octicon-plus'
    elsif action_type.eql?(Journal::ACTION_UPDATE)
      'octicon octicon-pencil'
    elsif action_type.eql?(Journal::ACTION_DELETE)
      'octicon octicon-trashcan'
    end
  end

  def journal_object_type(journal)
    type = journal.journalized_type
    if type.eql?('Issue') && !journal.action_type.eql?(Journal::ACTION_DELETE)
      "#{journal.issue.tracker.caption} "
      link_to journal.issue.caption, issue_path(journal.project.slug, journal.journalized_id)
    else
      content_tag :b, "#{type} #{journal.journalized_identifier}"
    end
  end

  def members_list(members_hash)
    content_tag :div do
      members_hash.collect do |role, members|
        safe_concat content_tag :h4, role
        safe_concat content_tag :ul, members.collect { |member| content_tag :li, member.caption }.join.html_safe
      end.join.html_safe
    end
  end


  def project_list(projects, allow_to_star)
    content_tag :ul, class: "project_list #{allow_to_star ? 'sortable' : '' }" do
      projects.collect do |project|
        content_tag :li, class: "#{project.is_archived ? 'archived' : ''} project", id: project.id do
          safe_concat project_stats(project).html_safe
          safe_concat link_to mega_glyph(project.name, 'repo'), overview_projects_path(project.slug)
          safe_concat content_tag :p, class: 'project_last_activity', &Proc.new {
            project.last_activity_info
          }
          project_list_star_button(project) if allow_to_star
        end
      end.join.html_safe
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
          link_to(glyph(t(:link_unstar), 'star'), star_project_profile_path(project.id), {:class => 'icon icon-fav starred star', :method => :post, :remote => true})
        else
          link_to(glyph(t(:link_star), 'star'), star_project_profile_path(project.id), {:class => 'icon icon-fav-off star', :method => :post, :remote => true})
        end
      }
    }
  end


end