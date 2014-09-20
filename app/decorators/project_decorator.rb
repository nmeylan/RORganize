class ProjectDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::delete_attachment_link.
  def delete_attachment_link(attachment)
    if User.current.allowed_to?('update_project_informations', 'settings', model)
      h.link_to h.glyph(h.t(:link_delete), 'trashcan'), h.delete_attachment_settings_path(self.slug, attachment.id), {:remote => true, 'data-confirm' => h.t(:text_delete_item), :method => :delete}
    end
  end

  # Render last activity info.
  def last_activity_info
    last_activity = model.journals[0]
    unless last_activity.nil?
      %Q(#{h.t(:text_last_activity)} #{h.distance_of_time_in_words(last_activity.created_at.to_formatted_s, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{last_activity.user ? last_activity.user.name : t(:label_unknown)}.)
    end
  end

  # Render list of members grouped by their roles.
  def display_members
    members_hash = Hash.new { |h, k| h[k] = [] }
    non_member = Role.non_member
    self.members.each do |member|
      members_hash[member.role.caption] << member unless member.role.eql?(non_member)
    end
    h.members_list(members_hash)
  end

  # Render an overview report of running versions of the project.
  def display_version_overview
    versions = model.current_versions.decorate
    condition = %Q(`versions`.`id` IN (#{current_versions.collect { |version| version.id }.join(',')})) if versions.to_a.any?
    versions_overviews = Version.overviews(self.id, condition)
    structure = Hash.new { |k, v| k[v] = {} }
    versions_overviews.each do |version_overview|
      structure[version_overview.first] = {
          percent: version_overview[3].truncate, closed_issues_count: version_overview[2], opened_issues_count: version_overview[1]
      }
    end
    if versions.to_a.any?
      versions.each do |version|
        unless structure.keys.include?(version.id)
          structure[version.id] = {
              percent: 100, closed_issues_count: 0, opened_issues_count: 0
          }
        end
      end
      h.versions_list_overview(versions, structure)
    else
      h.content_tag :div, h.t(:text_no_running_versions), class: 'no-data'
    end
  end

  # Draw roadmap of the projects.
  # @param [Array] versions an array of running versions.
  def display_roadmap(versions)
    versions_overviews = Version.overviews(self.id)
    structure = Hash.new { |k, v| k[v] = {} }
    versions_overviews.each do |version_overview|
      version = versions.select { |v| v.id.eql?(version_overview[0]) }.first
      issues = version ? version.issues : []
      structure[version_overview.first] = {
      percent: version_overview[3].truncate, closed_issues_count: version_overview[2], opened_issues_count: version_overview[1], issues: issues}
    end
    p structure
    if versions.to_a.any? && versions.to_a.first.issues.size > 0
      versions.each do |version|
        unless structure.keys.include?(version.id)
          structure[version.id] = {
              percent: 100, closed_issues_count: 0, opened_issues_count: 0
          }
        end
      end
      h.draw_roadmap(versions, structure)
    else
      h.content_tag :div, h.t(:text_no_data), class: 'no-data'
    end
  end

end
