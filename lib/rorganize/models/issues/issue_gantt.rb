# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_dates_validator.rb
module Rorganize
  module Models
    module Issues
      module IssueGantt

        module ClassMethods
          # @param [Hash] issue_id_attributes_changed_hash containing {issue_id: {attribute: new_value}}
          # attributes are 'start_date' or 'due_date'
          def gantt_edit(issue_id_attributes_changed_hash, project)
            errors = []
            Issue.transaction do
              issue_id_attributes_changed_hash.each do |issue_id, attribute_name_value_hash|
                issue = project.issues.find_by_sequence_id(issue_id)
                if issue
                  issue.attributes = attribute_name_value_hash
                  issue.predecessor = Issue.find_by_sequence_id_and_project_id(attribute_name_value_hash[:predecessor_id], issue.project_id) if attribute_name_value_hash[:predecessor_id]
                  if issue.changed?
                    issue.save
                    issue.errors.messages
                    errors << issue.errors.messages if issue.errors.messages.any?
                  end
                end
              end
              errors
            end
          end
        end

        # @param [Numeric] predecessor_id : the predecessor id.
        # @return [Hash] a hash with the following structure:
        # {saved: Boolean, journals: Array}
        def set_predecessor(predecessor_id)
          self.predecessor = Issue.find_by_sequence_id_and_project_id(predecessor_id, self.project_id)
          saved = self.save
          journals = Journal.where(journalizable_type: 'Issue', journalizable_id: self.id).includes([:details, :user])
          {saved: saved, journals: journals}
        end

        def validate_predecessor
          unless self.predecessor_id.nil?
            issue = Issue.find_by_id(self.predecessor_id)
            if predecessor_not_exists?(issue)
              errors.add(:predecessor, 'not exist in this project')
            elsif predecessor_is_self?(issue)
              errors.add(:predecessor, "can't be self")
            elsif predecessor_is_a_child?(issue)
              errors.add(:predecessor, 'is already a child')
            end
          end
        rescue
          errors.add(:predecessor, 'not found')
        end

        def predecessor_is_a_child?(issue)
          !issue.nil? && self.children.include?(issue)
        end

        def predecessor_is_self?(issue)
          !issue.nil? && issue.id.eql?(self.id)
        end

        def predecessor_not_exists?(issue)
          !issue.nil? && !issue.project_id.eql?(self.project_id) || issue.nil?
        end

      end
    end
  end
end