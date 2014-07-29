# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: journals_helper.rb

module JournalsHelper
  def display_activities(activities, to, from)
    activities_range(to, from) +
        (content_tag :div, class: 'activities', &Proc.new {
          if activities.content.to_a.any?
            i = 0
            activities.content.each do |date, objects|
              i += 1
              safe_concat activities_date(date)
              safe_concat content_tag :div, class: "journals", &Proc.new {
                activities_render(activities, date, objects)
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
  def activities_render(activities, date, objects)
    i = 0
    objects.keys.each do |polymorphic_identifier|
      act = activities.content_for(date, polymorphic_identifier)
      safe_concat one_journal_render(act, act.at(0), i)
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
    user = journal.display_author
    if nth % 2 == 0
      safe_concat content_tag :span, nil, class: "#{journal.display_action_type_icon}"
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal.display_action_type, class: 'action_type'
      safe_concat content_tag :span, journal.display_object_type, class: 'object_type'
      safe_concat content_tag :span, journal.display_creation_at, class: 'date'
    else
      safe_concat content_tag :span, journal.display_creation_at, class: 'date'
      safe_concat content_tag :span, nil, class: "#{journal.display_action_type_icon}"
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal.display_action_type, class: 'action_type'
      safe_concat content_tag :span, journal.display_object_type, class: 'object_type'
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
              safe_concat journal.display_creation_at
            }
            safe_concat content_tag :span, journal.display_author, class: 'author'
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