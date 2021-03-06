# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: links_helper.rb

module LinksHelper
# Build an add attachments link
# @param [String] caption : link caption.
# @param [ActiveRecord::Base] object that belongs to this attachment.
# @param [Class] type : type of the object that belongs to this attachment.
  def add_attachments_link(caption, object, type)
    content = escape_once(render partial: 'shared/attachments', locals: {attachments: Attachment.new, object: object, type: type})
    link_to caption, '#', {class: 'add-attachment-link', 'data-content' => content}
  end

  # Build a link to user profile.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [User|String] user or user name.
  def fast_profile_link(user)
    slug = user.is_a?(User) ? user.slug : user.downcase.tr(' ', '-')
    caption = user.is_a?(User) ? user.caption : user
    "<a href='/#{slug}' class='author-link' >#{caption}</a>".html_safe
  end

  # Build a link to project overview.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Project] project.
  def fast_project_link(project)
    "<a href='/projects/#{project.slug}/overview'>#{project.caption}</a>".html_safe
  end

  # Build a link to issue show action.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Issue] issue.
  # @param [Project] project.
  def fast_issue_link(issue, project)
    "<a href='/projects/#{project.slug}/issues/#{issue.sequence_id}'>#{resize_text(issue.caption, 35)}</a>".html_safe
  end


  # Build an avatar renderer for the given user.
  # @param [User] user.
  def fast_user_small_avatar(user)
    "<img alt='' class='small-avatar' src='/system/attachments/Users/#{user.id}/#{user.avatar.id}/very_small/#{user.avatar.avatar_file_name}'>".html_safe
  end

  # Build a link to issue show action.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Document] document.
  # @param [Project] project.
  def fast_document_link(document, project)
    "<a href='/projects/#{project.slug}/documents/#{document.sequence_id}'>#{resize_text(document.caption, 35)}</a>".html_safe
  end

  def fast_wiki_page(wiki_page, project)
    "<a href='/projects/#{project.slug}/wiki_pages/#{wiki_page.slug}'>#{resize_text(wiki_page.caption, 35)}</a>".html_safe
  end

  # Render a link to watch all activities from watchable.
  # @param [ActiveRecord::base] watchable : a model that include Watchable module.
  # @param [Project] project : the project which belongs to watchable.
  # @param [boolean] label : tooltip label.
  def toggle_watcher_link(watchable, project, is_watch = false)
    if is_watch
      label = t(:text_watch)
      id = "unwatch"
      caption = t(:link_unwatch)
    else
      label = t(:text_unwatch)
      id = "watch"
      caption = t(:link_watch)
    end

    link_to glyph(caption, 'eye'), toggle_watchers_path(project.slug, watchable.class.to_s, watchable.id),
            {id: "#{id}-link-#{watchable.id}", class: 'tooltipped tooltipped-s button', remote: true, method: :post, label: label}
  end

  # @param [User] user : current user.
  # @return [String] build a link to notifications panel. Link changed if there are new notifications or not.
  def notification_link(user)
    if user.notified?
      new_notification_link
    else
      link_to glyph('', 'inbox'), notifications_path, {class: "#{params[:controller].eql?('notifications') ? 'selected' : ''}"}
    end
  end

  def new_notification_link
    link_to notifications_path, {class: "tooltipped tooltipped-s indicator #{params[:controller].eql?('notifications') ? 'selected' : ''}", label: t(:text_unread_notifications)} do
      concat content_tag :span, nil, {class: 'unread inbox'}
      concat glyph('', 'inbox')
    end
  end
end