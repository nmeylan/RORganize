# Author: Nicolas Meylan
# Date: 04.07.14
# Encoding: UTF-8
# File: issue_filter.rb

require 'projects/project_item_filter_part'
class IssueFilter < ProjectItemFilterPart
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
    assigned_to_filter(content_hash, members)
    author_filter(content_hash, members)
    category_filter(content_hash)
    created_at_filter(content_hash)
    done_filter(content_hash)
    due_date_filter(content_hash)
    status_filter(content_hash)
    start_date_filter(content_hash)
    subject_filter(content_hash)
    tracker_filter(content_hash)
    version_filter(content_hash)
    updated_at_filter(content_hash)
    content_hash
  end

  def tracker_filter(content_hash)
    tracker_options = @project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    build_hash_for_radio(content_hash, 'tracker')
    build_hash_for_select(content_hash, 'tracker', tracker_options)
  end

  def subject_filter(content_hash)
    build_hash_for_radio(content_hash, 'subject', %w(all contains not_contains))
  end

  def start_date_filter(content_hash)
    build_hash_for_radio_date(content_hash, 'start')
  end

  def status_filter(content_hash)
    status_options = IssuesStatus.eager_load(:enumeration).collect { |status| [status.enumeration.name, status.id] }
    build_hash_for_select(content_hash, 'status', status_options)
    build_hash_for_radio(content_hash, 'status', %w(all equal different open close))
  end

  def due_date_filter(content_hash)
    build_hash_for_radio_date(content_hash, 'due_date')
  end

  def done_filter(content_hash)
    done_options = [[0, 0], [10, 10], [20, 20], [30, 30], [40, 40], [50, 50], [60, 60], [70, 70], [80, 80], [90, 90], [100, 100]]
    build_hash_for_radio(content_hash, 'done', %w(all equal superior inferior))
    build_hash_for_select(content_hash, 'done', done_options)
  end

  def author_filter(content_hash, members)
    author_options = members.collect { |member| [member.user.name, member.user.id] }
    build_hash_for_select(content_hash, 'author', author_options)
    build_hash_for_radio(content_hash, 'author')
  end

  def assigned_to_filter(content_hash, members)
    assigned_to_options = members.collect { |member| [member.user.name, member.user.id] } << %w(Nobody NULL)
    build_hash_for_select(content_hash, 'assigned', assigned_to_options)
    build_hash_for_radio(content_hash, 'assigned')
  end
end