# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_dates_validator.rb
module Rorganize
  module Models
    module Issues
      module IssueGantt

        module ClassMethods
          # @param [Hash] hash containing {issue_id: {attribute: new_value}}
          def gantt_edit(hash)
            errors = []
            Issue.transaction do
              hash.each do |k, v|
                issue = Issue.find_by_id(k)
                if issue
                  issue.attributes = v
                  if issue.changed?
                    issue.save
                    errors << issue.errors.messages if issue.errors.messages.any?
                  end
                end
              end
              errors
            end
          end
        end

        def validate_predecessor
          unless self.predecessor_id.nil?
            issue = Issue.find(self.predecessor_id)
            if predecessor_not_exists?(issue)
              errors.add(:predecessor, 'not exist in this project')
            elsif predecessor_is_self?(issue)
              errors.add(:predecessor, "can't be self")
            elsif predecessor_is_a_child(issue)
              errors.add(:predecessor, 'is already a child')
            end
          end
        rescue
          errors.add(:predecessor, 'not found')
        end

        def predecessor_is_a_child(issue)
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