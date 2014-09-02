class ProjectDecorator < ApplicationDecorator
  delegate_all

  def delete_attachment_link(attachment)
    super(h.delete_attachment_settings_path(self.slug, attachment.id), self)
  end

  def last_activity_info
    last_activity = model.journals[0]
    unless last_activity.nil?
      %Q(#{h.t(:text_last_activity)} #{h.distance_of_time_in_words(last_activity.created_at.to_formatted_s, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{last_activity.user ? last_activity.user.name : t(:label_unknown)}.)
    end
  end

  def display_members
    members_hash = Hash.new { |h, k| h[k] = [] }
    self.members.each do |member|
      members_hash[member.role.caption] << member
    end
    h.members_list(members_hash)
  end

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

  def display_roadmap(versions)
    versions_overviews = Version.overviews(self.id)
    issues_array = Issue.eager_load(:status, :tracker, :version).where(project_id: self.id)
    structure = Hash.new { |k, v| k[v] = {} }
    versions_overviews.each do |version_overview|
      structure[version_overview.first] = {
          percent: version_overview[3].truncate, closed_issues_count: version_overview[2], opened_issues_count: version_overview[1], issues: issues_array.select { |issue| issue.version_id.eql?(version_overview.first) }
      }
    end
    if versions.to_a.any?
      h.draw_roadmap(versions, structure)
    else
      h.content_tag :div, h.t(:text_no_data), class: 'no-data'
    end
  end

end
