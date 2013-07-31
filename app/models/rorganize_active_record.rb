#Author : Nicolas Meylan
#Date: 18 juil. 2013 
#Encoding: UTF-8
#File: journalized_record

class RorganizeActiveRecord < ActiveRecord::Base
  include Rorganize::JournalizedRecordCallback
  self.abstract_class = true
end