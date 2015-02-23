# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journal_detail.rb

class JournalDetail < ActiveRecord::Base
  belongs_to :journal, class_name: 'Journal'


  # @param [Numeric] project_id : delete all orphans journal details for this project id.
  def self.delete_all_orphans(project_id)
    journals_id = Journal.where(project_id: project_id).pluck('id')
    JournalDetail.delete_all("journal_id IN (#{journals_id.join(',')})") unless journals_id.empty?
  end
end

