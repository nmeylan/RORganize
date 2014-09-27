# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issue_filter.rb

class IssueFilter
  attr_reader :content

  def initialize(project)
    @project = project
    @content = build_filter
  end

  # Return a hash with the content requiered for the filter's construction
  # Can define 2 type of filters:
  # Radio : with values : all - equal/contains - different/not contains
  # Select : for attributes which only defined values : e.g : version => [1,2,3]
  # @return [Hash] with the content requiered for the filter's construction
  def build_filter
    content_hash = {}
    members = @project.real_members
    content_hash['hash_for_select'] = {}
    content_hash['hash_for_radio'] = Hash.new { |k, v| k[v] = [] }
    content_hash['hash_for_select']['assigned'] = members.collect { |member| [member.user.name, member.user.id] }
    content_hash['hash_for_radio']['assigned'] = %w(all equal different)
    content_hash['hash_for_select']['assigned'] << %w(Nobody NULL)
    content_hash['hash_for_select']['author'] = members.collect { |member| [member.user.name, member.user.id] }
    content_hash['hash_for_radio']['author'] = %w(all equal different)
    content_hash['hash_for_select']['category'] = @project.categories.collect { |category| [category.name, category.id] }
    content_hash['hash_for_radio']['category'] = %w(all equal different)
    content_hash['hash_for_radio']['created'] = %w(all equal superior inferior today)
    content_hash['hash_for_radio']['done'] = %w(all equal superior inferior)
    content_hash['hash_for_select']['done'] = [[0, 0], [10, 10], [20, 20], [30, 30], [40, 40], [50, 50], [60, 60], [70, 70], [80, 80], [90, 90], [100, 100]]
    content_hash['hash_for_radio']['due_date'] = %w(all equal superior inferior today)
    content_hash['hash_for_select']['status'] = IssuesStatus.eager_load(:enumeration).collect { |status| [status.enumeration.name, status.id] }
    content_hash['hash_for_radio']['status'] = %w(all equal different open close)
    content_hash['hash_for_radio']['start'] = %w(all equal superior inferior today)
    content_hash['hash_for_radio']['subject'] = %w(all contains not_contains)
    content_hash['hash_for_select']['tracker'] = @project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    content_hash['hash_for_radio']['tracker'] = %w(all equal different)
    content_hash['hash_for_select']['version'] = @project.versions.collect { |version| [version.name, version.id] }
    content_hash['hash_for_select']['version'] << %w(Unplanned NULL)
    content_hash['hash_for_radio']['version'] = %w(all equal different)
    content_hash['hash_for_radio']['updated'] = %w(all equal superior inferior today)
    content_hash
  end
end