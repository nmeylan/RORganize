# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: content.rb

class FormContent
  attr_reader :content
  def initialize(project)
    @content = {}
    @content['allowed_statuses'] = User.current.allowed_statuses(project).collect { |status| [status.enumeration.name, status.id] }
    @content['done_ratio'] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    @content['members'] = project.real_members.collect { |member| [member.user.name, member.user.id] }
    @content['categories'] = project.categories.collect { |category| [category.name, category.id] }
    @content['trackers'] = project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    @content
  end
end