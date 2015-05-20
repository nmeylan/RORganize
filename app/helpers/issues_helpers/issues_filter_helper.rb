# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issues_overview_helper.rb

module IssuesHelpers
  module IssuesFilterHelper
    # Build a json filter form.
    def generics_form_to_json
      issue_filter = IssueFilter.new(@project)
      filter_content_hash = issue_filter.content
      hash_for_radio = filter_content_hash['hash_for_radio']
      hash_for_select = filter_content_hash['hash_for_select']
      form_hash = build_form_hash(hash_for_radio, hash_for_select)
      issue_filter.build_json_form(form_hash)
    end

    def build_form_hash(hash_for_radio, hash_for_select)
      form_hash = {}
      form_hash['assigned_to'] = generic_filter(:simple_select, 'Assigned to', 'assigned_to', hash_for_radio['assigned'], hash_for_select['assigned'], true, nil)
      form_hash['author'] = generic_filter(:simple_select, 'Author', 'author', hash_for_radio['author'], hash_for_select['author'])
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
      form_hash
    end
  end
end