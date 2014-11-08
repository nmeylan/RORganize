# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: roadmap_report.rb

class RoadmapReport
  attr_reader :version_decorator, :old_versions
  def initialize(project_decorator)
    @version_decorator = project_decorator.model.versions.where(is_done: false).eager_load(issues: [:status, :tracker]).order(:position).decorate
    unplanned = Version.new(name: 'Unplanned')
    unplanned.issues << Issue.where(project_id: project_decorator.id, version_id: nil).eager_load(:status, :tracker)
    unplanned.project = project_decorator.model
    @version_decorator.to_a << unplanned.decorate
    @old_versions = project_decorator.old_versions.decorate
  end
end