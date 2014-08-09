# Author: Nicolas Meylan
# Date: 06.08.14
# Encoding: UTF-8
# File: rorganize_markdown_renderer.rb

class RorganizeMarkdownRenderer < Redcarpet::Render::HTML
  include ActionView::Helpers
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  STRIKETHROUGH_REGEX = /~~[^~~][^~~]*~~/
  EMPTY_TASK_REGEX = /-\s\[\s\]\s.*/
  COMPLETE_TASK_REGEX = /-\s\[x\]\s.*/
  TASK_REGEX = /\s*-\s\[(\s|x)\]\s*/
  TASKS_LIST_REGEX = /(^(\s*-\s\[(\s|x)\]\s*.*\n?)+$)/
  USER_LINK_REGEX= /@[^\s]+/
  LF ='\n'

  def initialize(options = {}, context = {})
    super(options)
    @options = options
    @context = context
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
    document
  end

  def issue_link_renderer(document)
    raise 'project_slug should be given in context hash. context[:project_slug]' if @context[:project_slug].nil?
    document.gsub(/#\d+/) do |occurrence| #Replace all #number by a link to issue with id == number
      link_to occurrence, url_for({project_id: @context[:project_slug], id: occurrence.match(/\d+/).to_s, controller: 'issues', action: 'show'})
    end
  end

  def task_list_renderer(document)
    i = 0
    document.gsub(TASKS_LIST_REGEX) do |task_list|
      list = '<ul class="task_list">'
      list += task_list.gsub(COMPLETE_TASK_REGEX) do |complete_task|
        i += 1
        '<li><input type="checkbox" class="task-list-item-checkbox" data-index='+i.to_s+' disabled="" checked="">'+complete_task.gsub(TASK_REGEX, '')+'</li>'
      end.gsub(EMPTY_TASK_REGEX) do |empty_task|
        i += 1
        '<li><input type="checkbox" class="task-list-item-checkbox" data-index='+i.to_s+' disabled="">'+empty_task.gsub(TASK_REGEX, '')+'</li>'
      end
      list += '</ul>'
      list
    end
  end

  def user_link_renderer(document)
    document.gsub(USER_LINK_REGEX) do |user_link|
      link_to user_link, url_for(controller: 'rorganize', action: 'view_profile', user: user_link.gsub(/@/, ''))
    end
  end

end