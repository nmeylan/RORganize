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
end