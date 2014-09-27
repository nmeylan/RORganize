# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journal_detail.rb

class JournalDetail < ActiveRecord::Base
  belongs_to :journal, :class_name => 'Journal'


end

