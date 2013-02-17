# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journal.rb

class Journal < ActiveRecord::Base
  has_many :details, :class_name => 'JournalDetail', :dependent => :destroy
  belongs_to :user, :class_name => 'User'
end
