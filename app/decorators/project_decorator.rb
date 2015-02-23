class ProjectDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::delete_attachment_link.
  def delete_attachment_link(attachment)
    if User.current.allowed_to?('update_project_informations', 'settings', model)
      h.link_to h.glyph(h.t(:link_delete), 'trashcan'), h.delete_attachment_settings_path(self.slug, attachment.id),
                {remote: true, 'data-confirm' => h.t(:text_delete_item), method: :delete}
    end
  end

  # Render last activity info.
  def latest_activity_info
    last_activity = model.latest_activity
    unless last_activity.nil?
      %Q(#{h.t(:text_latest_activity)} #{h.distance_of_time_in_words(last_activity.created_at.to_formatted_s, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{last_activity.user ? last_activity.user.name : h.t(:label_unknown)}.)
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
    condition = %Q(versions.id IN (#{versions.collect(&:id).join(',')})) if versions.to_a.any?
    versions_overviews = Version.overviews(self.id, condition)
    structure = build_overview_report_stats(versions_overviews)
    render_versions_overview(structure, versions, h.t(:text_no_versions)) do
      h.versions_list_overview(versions, structure)
    end
  end

  # Draw roadmap of the projects.
  # @param [Array] versions an array of running versions.
  def display_roadmap(versions)
    versions_overviews = Version.overviews(self.id)
    issues = versions.inject({}) { |memo, version| memo[version.id] = version.issues; memo }
    structure = build_overview_report_stats(versions_overviews, issues)
    render_versions_overview(structure, versions, h.t(:text_no_versions), true) do
      h.draw_roadmap(versions, structure)
    end
  end

  # @param [Array] versions_overviews : an array with this structure :
  # [[version_id, number of opened issues, number of closed issues, progress percent of issue]
  # @param [Hash] issues : a hash
  def build_overview_report_stats(versions_overviews, issues = {})
    versions_overviews.inject({}) do |structure, version_overview|
      structure[version_overview.first] = {percent: version_overview[3].truncate,
                                           closed_issues_count: version_overview[2],
                                           opened_issues_count: version_overview[1]}
      structure[version_overview.first].merge!({issues: issues[version_overview[0]]}) unless issues.empty?
      structure
    end
  end

  def render_versions_overview(structure, versions, no_data_text, no_data_large = false)
    if versions.to_a.any?
      version_overview_init_nil_structure(structure, versions)
      yield if block_given?
    else
      h.no_data(no_data_text, 'milestone', no_data_large)
    end
  end

  def version_overview_init_nil_structure(structure, versions)
    versions.each do |version|
      structure[version.id] = {percent: 0, closed_issues_count: 0, opened_issues_count: 0} unless structure.keys.include?(version.id)
    end
  end

end
