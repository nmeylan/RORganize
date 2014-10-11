# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: filter_helper.rb

module FilterHelper
# Build a filter form for given criteria.
# @param [String] label : what is filtered (e.g : issues, documents).
# @param [Array] filtered_attributes : an array of filtered attribute @see Document.filtered_attributes.
# @param [String] submission_path : the path to controller when the filter form is submit.
# @param [Boolean] can_save : false when save button is hidden, true otherwise.
# @param [hash] save_button_options
  def filter_tag(label, filtered_attributes, submission_path, can_save = false, save_button_options = {})
    content_tag :fieldset, id: "#{label}-filter" do
      safe_concat content_tag :legend, link_to(glyph(t(:link_filter), 'chevron-right'), '#', {class: 'icon-collapsed toggle', id: "#{label}"})
      safe_concat filter_tag_content(can_save, filtered_attributes, save_button_options, submission_path)
    end
  end

  def filter_tag_content(can_save, filtered_attributes, save_button_options, submission_path)
    content_tag :div, class: 'content' do
      safe_concat filter_form_tag(filtered_attributes, save_button_options, can_save, submission_path)
    end
  end

  # @param [Array] filtered_attributes : an array of filtered attribute @see Document.filtered_attributes.
  # @param [String] submission_path : the path to controller when the filter form is submit.
  # @param [Boolean] can_save : false when save button is hidden, true otherwise.
  # @param [hash] save_button_options
  def filter_form_tag(filtered_attributes, save_button_options, can_save, submission_path)
    form_tag submission_path, {method: :get, class: 'filter-form', id: 'filter-form', remote: true} do
      filter_type_choice_tag
      safe_concat filter_attribute_choice_tag(filtered_attributes)
      safe_concat content_tag :table, nil, id: 'filter-content'
      safe_concat submit_tag t(:button_apply), {style: 'margin-left:0px'}
      safe_concat content_tag :span, save_filter_button_tag(can_save, save_button_options[:filter_content],
                                                            save_button_options[:user],
                                                            save_button_options[:project]),
                              {id: 'save-query-button'}
    end
  end

  # Build a save button for filter : based on user permissions (does user is allowed to create custom queries?)
  # @param [Boolean] can_save : false when save button is hidden, true otherwise.
  # @param [Array] filtered_content : an array of previous submitted filter, it use because if nothing were filtered then whe don't display the button.
  # @param [User] user : the current user.
  # @param [Project] project : current project.
  def save_filter_button_tag(can_save, filter_content, user, project)
    if can_user_save_query?(can_save, filter_content, project, user, params[:query_id].nil?)
      link_to t(:button_save), new_project_query_queries_path(project.slug, 'Issue'), {remote: true}
    elsif can_user_save_query?(can_save, filter_content, project, user, !params[:query_id].nil?)
      link_to t(:button_save), edit_query_filter_queries_path(params[:query_id]), {id: 'filter-edit-save'}
    end
  end

  def can_user_save_query?(can_save, filter_content, project, user, create_or_edit)
    can_save && !filter_content.eql?('') && user.allowed_to?('new', 'Queries', project) && create_or_edit
  end

  def filter_attribute_choice_tag(filtered_attributes)
    content_tag :div, class: 'autocomplete-combobox nosearch no-padding-left no-height' do
      select_tag 'filters_list', options_for_select(filtered_attributes), class: 'chzn-select cbb-verylarge', id: 'filters-list', multiple: true
    end
  end

  # @return [String] build filter type choice.
  def filter_type_choice_tag
    safe_concat radio_button_tag('type', 'all', true, {align: 'center', id: 'type-all'})
    safe_concat label_tag('type-all', t(:label_all))
    safe_concat radio_button_tag 'type', 'filter', false, id: 'type-filter'
    safe_concat label_tag 'type-filter', t(:link_filter)
  end



  # Build filter form input.
  # @param [Symbol] filter_type : type of the filtered link. values are :simple_select, :text, :date.
  # @param [String] label.
  # @param [String] name of the input.
  # @param [Array] options_for_radio : this array must contains one or more of these values
  # ('all', 'contains', 'not_contains', 'equal', 'superior', 'inferior', 'different', 'today', 'open', 'close').
  # @param [Object] args : for simple_select are  ('options_for_select', 'multiple', 'size').
  def generic_filter(filter_type, label, name, options_for_radio, *args)
    types = %w(:simple_select :date :text)
    label ||= name.capitalize
    filter = case filter_type
               when :simple_select then
                 generics_filter_simple_select(name, *args)
               when :date then
                 generics_filter_date_field(name)
               when :text then
                 generics_filter_text_field(name)
               else
                 raise Exception, "Filter with type : :#{filter_type}, doesn't exist! Allowed types are : #{types.join(', ')}"
             end
    content_tag :tr, class: name do
      safe_concat content_tag :td, label, class: 'label'
      safe_concat content_tag :td, generics_filter_radio_button(name, options_for_radio).html_safe, class: 'radio'
      safe_concat content_tag :td, filter, id: "td-#{name}", class: 'value'
    end
  end


  # For following filter: e.g: Assigned with 3 radio button (All, equal, different) and 1 combo
  # @param [String] name : name of the input field.
  # @param [Object] options_for_select : options for select.
  # @param [Boolean] multiple : true multiple select enabled, disabled otherwise.
  # @param [Object] size
  def generics_filter_simple_select(name, options_for_select, multiple = true, size = nil)
    size ||= 'cbb-large'
    content_tag :div, class: 'autocomplete-combobox nosearch no-padding-left no-height' do
      select_tag("filter[#{name}][value][]", options_for_select(options_for_select), class: 'chzn-select '+size, id: name+'_list', multiple: multiple)
    end
  end

  # For filters that require data from text field: e.g subject.
  # @param [String] name : name of the input field.
  def generics_filter_text_field(name)
    text_field_tag("filter[#{name}][value]", '', {size: 80})
  end

  # For filters that require data from date field: e.g created_at.
  # @param [String] name : name of the input field.
  def generics_filter_date_field(name)
    date_field_tag("filter[#{name}][value]", '', {size: 6, id: 'calendar-'+name, class: 'calendar'})
  end

  # @param [String] name : name of the input field.
  # @param [Array] ary : array of radio names.
  def generics_filter_radio_button(name, ary)
    content_tag :span do
      ary.each do |v|
        safe_concat radio_button_tag %Q(filter[#{name}][operator]), v, v.eql?('all'), {class: name, id: %Q(#{name}_#{v.tr(' ', '_')}), align: 'center'}
        safe_concat label_tag %Q(#{name}_#{v}), v.tr('_', ' ').capitalize
      end
    end
  end

end