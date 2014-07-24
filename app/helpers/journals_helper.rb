# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: journals_helper.rb

module JournalsHelper
  def display_activities(activities, to, from)
    activities_range(to, from) +
        (content_tag :div, class: 'activities', &Proc.new {
          if activities.to_a.any?
            i = 0
            activities.each do |date, item|
              i += 1
              safe_concat activities_date(date)
              safe_concat content_tag :div, class: "journals", &Proc.new {
                journals_render(item.compact.sort { |x, y| y.at(0).created_at <=> x.at(0).created_at })
              }
              safe_concat clear_both
            end
          else
            content_tag :div, t(:text_no_data), class: 'no-data'
          end
        })
  end

  def activities_range(to, from)
    content_tag :div, {class: 'activities_range'}, &Proc.new {
      safe_concat t(:text_from).capitalize + ' '
      safe_concat content_tag :span, from
      safe_concat ' ' + t(:text_to) + ' '
      safe_concat content_tag :span, to
      safe_concat '.'
    }
  end

  def activities_date(date)
    content_tag :div, class: 'date_circle', &Proc.new {
      content_tag :div, content_tag(:p, date), class: 'inner_circle'
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
        journal_detail_render(journals, nth)
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

  def journal_detail_render(journals, nth)
    first_journal = journals.at(0)
    safe_concat content_tag :div, class: 'journal_details', &Proc.new {
      safe_concat content_tag :span, link_to(t(:link_new_comment), '#'), class: 'detail comment octicon octicon-comment' unless first_journal.notes.empty?
      safe_concat content_tag(:ul, (first_journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
    }
    journals.delete_at(0)
    if journals.size > 0
      safe_concat link_to 'view more', '#', {class: 'toggle'}
      safe_concat content_tag :div, class: 'journal_details hide more', &Proc.new {
        journals.each do |journal|
          safe_concat content_tag :div, class: 'detail more', &Proc.new {
            safe_concat content_tag :span, link_to(t(:link_new_comment), '#'), class: 'detail comment octicon octicon-comment' unless journal.notes.empty?
            safe_concat content_tag :span, class: 'date', &Proc.new {
              safe_concat journal.created_at.strftime("%I:%M%p")
            }
            safe_concat content_tag :span, journal.user.caption, class: 'author'
            if journal.action_type.eql?(Journal::ACTION_UPDATE) && journal.details.to_a.any?
              safe_concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
            elsif journal.action_type.eql?(Journal::ACTION_CREATE)
              safe_concat t(:text_created_this_issue)
            end
          }
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
      safe_concat content_tag :b, "#{journal.issue.tracker.caption.downcase} "
      link_to journal.issue.caption, issue_path(journal.project.slug, journal.journalized_id)
    else
      content_tag :b, "#{type.downcase} #{journal.journalized_identifier}"
    end
  end

  def sidebar_types_selection(types, selected_types, period, date)
    labels = {'Issue' => t(:label_activity_type_issue), 'Category' => t(:label_activity_type_category), 'Document' => t(:label_activity_type_document),
              'Member' => t(:label_activity_type_member), 'Version' => t(:label_activity_type_version), 'Wiki' => t(:label_activity_type_wiki),
              'WikiPage' => t(:label_activity_type_wiki_page)}
    periods = {ONE_DAY: t(:label_activity_period_one_day), THREE_DAYS: t(:label_activity_period_three_days), ONE_WEEK: t(:label_activity_period_one_week), ONE_MONTH: t(:label_activity_period_one_month)}
    select_values = Hash[Journal::ACTIVITIES_PERIODS.keys.map { |period| [periods[period], period] }]
    project_id = @project ? @project.slug : nil
    form_tag url_for({action: 'activity_filter', project_id: project_id}), {id: 'activities_filter', remote: true} do
      safe_concat content_tag :ul, class: '', &Proc.new {
        types.collect do |type|
          content_tag :li, class: 'activities_filter' do
            safe_concat check_box_tag "[types][#{type}]", 1, selected_types.include?(type), {class: 'filter_selection'}
            safe_concat label_tag "[types][#{type}]", labels[type], {class: ''}
          end
        end.join.html_safe
      }
      safe_concat date_field_tag 'date', date, {class: 'filter_selection'}
      safe_concat content_tag :div, {class: 'autocomplete-combobox cbb-tiny nosearch', id: 'period_select'}, &Proc.new {
        select_tag 'period', options_for_select(select_values, period), {include_blank: false, class: 'filter_selection chzn-select-deselect cbb-tiny'}
      }
    end
  end

end