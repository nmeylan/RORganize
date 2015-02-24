# Author: Nicolas Meylan
# Date: 06.08.14
# Encoding: UTF-8
# File: rorganize_markdown_renderer.rb

class RorganizeMarkdownRenderer < Redcarpet::Render::HTML
  include ActionView::Helpers
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  STRIKETHROUGH_REGEX = /~~[^~~][^~~]*~~/
  COMPLETE_ELEMENT_REGEX = /\[x\]\s/
  EMPTY_ELEMENT_REGEX = /\[\s\]\s/
  TASKS_LIST_REGEX = /(^(\s*-\s\[(\s|x)\]\s*.*\n?)+$)/
  USER_LINK_REGEX= /@[^\s]+/
  LF ='\n'

  def initialize(options = {}, context = {})
    super(options)
    @options = options
    @context = context
    allow_task_list = !@context[:allow_task_list].nil? && @context[:allow_task_list]
    @task_list_edit = "#{allow_task_list ? 'enabled=""' : 'disabled=""'}"
  end

  def add_context(addition)
    @context.merge! addition
  end

  def preprocess(document)
    document.gsub!(STRIKETHROUGH_REGEX) do |occurrence| #Any ~~Strikethrough text~~
      "<s>#{occurrence.gsub(/~~/, '')}</s>"
    end

    document = user_link_renderer(document)
    document = task_list_renderer(document)
    document = issue_link_renderer(document) if @options[:issue_link_renderer]
    document
  end

  def postprocess(document)
    id = "#{@context[:element_type]}-#{@context[:element_id]}" if @context[:element_id] && @context[:element_type]
    document = add_class_to_task_list(document)
    "<div class='markdown-renderer' id='#{id}'>#{document}</div>"
  end

  def add_class_to_task_list(document)
    document.gsub(/(<ul>)\n(<li><input type="checkbox" class="task-list-item-checkbox")/) do |match|
      ul = "<ul class=\"task-list\">"
      ul + $2
    end
  end

  def issue_link_renderer(document)
    raise 'project_slug should be given in context hash. context[:project_slug]' if @context[:project_slug].nil?
    document.gsub(/#\d+/) do |occurrence| #Replace all #number by a link to issue with id == number
      link_to occurrence, url_for({project_id: @context[:project_slug], id: occurrence.match(/\d+/).to_s, controller: 'issues', action: 'show'})
    end
  end

  def task_list_renderer(document)
    document.gsub(TASKS_LIST_REGEX) do |task_list|
      list = ""
      list += task_list.gsub(COMPLETE_ELEMENT_REGEX) do
        "<input type=\"checkbox\" class=\"task-list-item-checkbox\" #{@task_list_edit} checked=\"\">"
      end.gsub(EMPTY_ELEMENT_REGEX) do
        "<input type=\"checkbox\" class=\"task-list-item-checkbox\" #{@task_list_edit}>"
      end
      list
    end
  end

  def user_link_renderer(document)
    document.gsub(USER_LINK_REGEX) do |user_link|
      if !@context[:from_mail]
        link_to user_link, url_for(controller: 'rorganize', action: 'view_profile', user: user_link.gsub(/@/, '')), {class: 'author-link'}
      else
        user_link
      end
    end
  end

end