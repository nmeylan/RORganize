# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_dates_validator.rb
module Rorganize
  module Models
    module IssueDatesValidator
      def self.included(base)
        base.extend(ClassMethods)
      end

#  Custom validator
      def validate_start_date
        if start_date_gt_due_date?
          errors.add(:start_date, "must be inferior than due date : #{self.due_date.to_formatted_s(:db)}")
        elsif start_date_gt_version_due_date?
          add_error_gt_version_due_date(:star_date)
        elsif start_date_lt_version_start_date?
          add_error_lt_version_start_date(:start_date)
        end
      end

      def validate_due_date
        if due_date_gt_version_due_date?
          add_error_gt_version_due_date(:due_date)
        elsif due_date_lt_version_start_date?
          add_error_lt_version_start_date(:due_date)
        end
      end

      # Set start date and due date based on version.
      # Rule :
      # Version.start_date <= Issue.start_date < Issue.due_date <= Version.due_date
      # So when issue's version is changing we have to update issue start and due date to respect the previous rule.
      def set_start_and_due_date(version_update = false)
        if update_due_date?(version_update)
          self.due_date = self.version.target_date
        end
        if update_start_date?(version_update)
          self.start_date = self.version.start_date
        end
        self
      end


      def update_start_date?(version_update)
        !self.new_record? && self.version && self.version.start_date && version_changed?(version_update) && (self.start_date.nil? || (start_date_lt_version_start_date?))
      end

      def update_due_date?(version_update)
        !self.new_record? && self.version && !self.version.target_date.nil? && due_date_gt_version_due_date_or_nil? && version_changed?(version_update)
      end

      def due_date_gt_version_due_date_or_nil?
        (self.due_date.nil? || self.due_date >= version.target_date)
      end

      def version_changed?(version_update)
        (version_update || self.version_id_changed?)
      end

      def start_date_lt_version_start_date?
        (self.start_date && self.version) && self.start_date < self.version.start_date
      end

      def start_date_gt_version_due_date?
        (self.start_date && self.version && self.version.target_date) && self.start_date >= self.version.target_date
      end

      def start_date_gt_due_date?
        (self.due_date && self.start_date) && self.start_date >= self.due_date
      end

      def due_date_lt_version_start_date?
        (self.due_date && self.version && self.version.start_date) && self.due_date <= self.version.start_date
      end

      def due_date_gt_version_due_date?
        (self.due_date && self.version && self.version.target_date) && self.due_date > self.version.target_date
      end

      private
      def add_error_lt_version_start_date(attribute)
        str = attribute.eql?(:due_date) ? 'superior' : 'superior or equal'
        errors.add(attribute, "must be #{str} than version start date : #{self.version.start_date.to_formatted_s(:db)}")
      end
      def add_error_gt_version_due_date(attribute)
        str = attribute.eql?(:start_date) ? 'inferior' : 'inferior or equal'
        errors.add(attribute, "must be #{str} than version due date : #{self.version.target_date.to_formatted_s(:db)}")
      end
    end

    module ClassMethods
      def bulk_set_start_and_due_date(issue_ids, version_id, journals)
        version = Version.find_by_id(version_id)
        issues = Issue.where(id: issue_ids)
        issue_changes = {due_date: [], start_date: []}
        bulk_change_start_due_date(issue_changes, issues)
        merged_issues = issue_changes[:due_date] | issue_changes[:start_date]
        if merged_issues.any?
          Issue.where(id: issue_changes[:due_date].collect { |issue| issue.id }).update_all(due_date: version.target_date)
          Issue.where(id: issue_changes[:start_date].collect { |issue| issue.id }).update_all(start_date: version.start_date)
          Issue.journal_update_creation(merged_issues, version.project, User.current.id, 'Issue', journals)
        end
      end

      def bulk_change_start_due_date(issue_changes, issues)
        issues.each do |issue|
          issue = issue.set_start_and_due_date(true)
          issue_changes[:due_date] << issue unless issue.changes[:due_date].nil?
          issue_changes[:start_date] << issue unless issue.changes[:start_date].nil?
        end
      end

    end

  end
end