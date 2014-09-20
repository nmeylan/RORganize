# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: journals_helper.rb

module JournalsHelper
  # Build a render for activities.
  # @param [Activities] activities object.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
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

  # Build a render of the date range of activities.
  # @param [Date] to : date range right border.(from..to)
  # @param [Date] from : date range left border.
  def activities_range(to, from)
    content_tag :div, {class: 'activities_range'}, &Proc.new {
      safe_concat t(:text_from).capitalize + ' '
      safe_concat content_tag :span, from
      safe_concat ' ' + t(:text_to) + ' '
      safe_concat content_tag :span, to
      safe_concat '.'
    }
  end

  # Build a render of the activities date.
  # @param [Date] date.
  def activities_date(date)
    content_tag :div, class: 'date_circle', &Proc.new {
      content_tag :div, content_tag(:p, date.strftime('%a. %-d %b.')), class: 'inner_circle'
    }
  end

  # Build a render all journals.
  # @param [Activities] activities.
  # @param [Date] date.
  # @param [Hash] objects a hash with this structure : {type_id: ['journalizable', 'journalizable', 'comment', 'journalizable']}
  def activities_render(activities, date, objects)
    i = 0
    objects.keys.each do |polymorphic_identifier|
      if i < 1000
        act = activities.content_for(date, polymorphic_identifier)
        safe_concat activity_render(act, act[0], i)
      else
        safe_concat content_tag :div, 'latest 1000 activities from this day were loaded.', {class: 'activity max'}
        break
      end
      i += 1
    end
  end

  # Build a render for one journalizable for same journalizable items. if two or more journals exists for one item the same day, they will be compact into one.
  # @param [Array] activities containing Journal or Comment.
  # @param [Journal|Comment] activity : the activity to render.
  # @param [Numeric] nth : the number of the activity to render for the same day.
  def activity_render(activities, activity, nth)
    content_tag :div, class: "activity #{nth % 2 == 0 ? 'odd' : 'even'}", &Proc.new {
      content_tag :p do
        if activity.is_a?(Journal)
          journal_header_render(activity, nth)
        elsif activity.is_a?(Comment)
          comment_header_render(activity, nth)
        end
        activity_detail_render(activities, nth)
      end
    }
  end

  # Build a render for journalizable content.
  # @param [Journal] journal.
  # @param [Numeric] nth : the number of the activity to render for the same day.
  def journal_header_render(journal, nth)
    user = journal.display_author(true)
    if nth % 2 == 0 #Render is depending on the parity
      safe_concat content_tag :span, nil, class: "#{journal.display_action_type_icon}"
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal.display_action_type, class: 'action_type'
      safe_concat content_tag :span, journal.display_object_type, class: 'object_type'
      journal.display_project_link(@project)
      safe_concat content_tag :span, journal.display_creation_at, class: 'date'
    else
      safe_concat content_tag :span, nil, class: "#{journal.display_action_type_icon}"
      safe_concat content_tag :span, journal.display_creation_at, class: 'date'
      safe_concat content_tag :span, user, class: 'author'
      safe_concat content_tag :span, journal.display_action_type, class: 'action_type'
      safe_concat content_tag :span, journal.display_object_type, class: 'object_type'
      journal.display_project_link(@project)
    end
  end

  # Build a render for journalizable content.
  # @param [Comment] comment.
  # @param [Numeric] nth : the number of the activity to render for the same day.
  def comment_header_render(comment, nth)
    if nth % 2 == 0 #Render is depending on the parity
      safe_concat content_tag :span, nil, class: "octicon octicon-comment activity_icon"
      safe_concat content_tag :span, comment.display_author, class: 'author'
      safe_concat comment.render_header
      comment.display_project_link(@project)
      safe_concat content_tag :span, comment.display_creation_at, class: 'date'
    else
      safe_concat content_tag :span, nil, class: "octicon octicon-comment activity_icon"
      safe_concat content_tag :span, comment.display_creation_at, class: 'date'
      safe_concat content_tag :span, comment.display_author, class: 'author'
      safe_concat comment.render_header
      comment.display_project_link(@project)
    end
  end

  # Build a render for activities detail.
  # @param [Array] activities containing Journal or Comment.
  # @param [Numeric] nth : the number of the activity to render for the same day.
  def activity_detail_render(activities, nth)
    first_activity = activities[0]
    safe_concat content_tag :div, class: 'journal_details', &Proc.new {
      if first_activity.is_a?(Journal)
        safe_concat content_tag(:ul, (first_activity.details.collect { |detail| history_detail_render(detail, true) }).join.html_safe)
      end
    }
    if activities.size - 1 > 0
      safe_concat link_to 'view more', '#', {class: 'toggle'}
      safe_concat content_tag :div, class: 'journal_details hide more', &Proc.new {
        i = 0
        activities.each do |activity|
          unless i == 0
            safe_concat content_tag :div, class: 'detail more', &Proc.new {
              safe_concat content_tag :span, class: 'date', &Proc.new {
                safe_concat activity.display_creation_at
              }
              safe_concat activity.render_details
            }
          end
          i += 1
        end
      }
    end
  end

  # Build a render for journal detail.
  # @param [JournalDetail] detail.
  def activity_history_detail_render(detail)
    if detail.old_value && (detail.value.nil? || detail.value.eql?(''))
      content_tag :li do
        safe_concat "#{t(:text_deleted)}"
        safe_concat content_tag :b, "#{detail.property} #{detail.old_value.to_s} "
      end
    elsif detail.old_value && detail.value
      content_tag :li do
        safe_concat t(:text_changed)
        safe_concat content_tag :b, " #{detail.property} "
        safe_concat "#{t(:text_from)} "
        safe_concat content_tag :b, "#{detail.old_value.to_s} "
        safe_concat "#{t(:text_to)} "
        safe_concat content_tag :b, "#{detail.value.to_s}"
      end
    else
      content_tag :li do
        safe_concat "#{t(:text_set_at)} "
        safe_concat content_tag :b, "#{detail.property} "
        safe_concat content_tag :b, "#{detail.value.to_s}"
      end
    end
  end

  # Build a render for the activities' sidebar.
  # @param [String] types : class name of Journalizable items.
  # @param [Array] selected_types : selected types.
  # @param [String] period : a value included in (ONE_DAY, THREE_DAYS, ONE_WEEK).
  # @param [Date] date : the selected date.
  # @param [User] user : provide when the sidebar is used in profile panel.
  def sidebar_types_selection(types, selected_types, period, date, user = nil)
    labels = {'Issue' => t(:label_activity_type_issue), 'Category' => t(:label_activity_type_category), 'Document' => t(:label_activity_type_document),
              'Member' => t(:label_activity_type_member), 'Version' => t(:label_activity_type_version), 'Wiki' => t(:label_activity_type_wiki),
              'WikiPage' => t(:label_activity_type_wiki_page)}
    periods = {ONE_DAY: t(:label_activity_period_one_day), THREE_DAYS: t(:label_activity_period_three_days), ONE_WEEK: t(:label_activity_period_one_week)}
    select_values = Hash[Journal::ACTIVITIES_PERIODS.keys.map { |period| [periods[period], period] }]
    project_id = @project_decorator ? @project_decorator.slug : nil
    form_tag url_for({action: 'activity_filter', project_id: project_id, user: user}), {id: 'activities_filter', remote: true} do
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