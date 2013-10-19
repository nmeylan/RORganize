# Author: Nicolas Meylan
# Date: 28 juil. 2012
# Encoding: UTF-8
# File: journal.rb

class Journal < ActiveRecord::Base
  
  has_many :details, :class_name => 'JournalDetail', :dependent => :destroy
  belongs_to :journalized, :polymorphic => true
  belongs_to :user, :class_name => 'User'

  belongs_to :project
  
  def deprecated_detail_insertion(updated_attributes, journalized_property)
    updated_attrs = updated_attributes
    updated_attrs.each do |attribute, old_new_value|
      old_value = old_new_value[0]
      new_value = old_new_value[1]
      JournalDetail.create(:journal_id => self.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end
  
  def detail_insertion(updated_attrs, journalized_property, foreign_key_value = {})
    #Remove attributes that won't be considarate in journal update
    updated_attrs.each do |attribute, old_new_value|
      if foreign_key_value[attribute]
        if foreign_key_value[attribute].eql?(IssuesStatus)
          old_value = foreign_key_value[attribute].find(old_new_value[0]).enumeration.name
          new_value = foreign_key_value[attribute].find(old_new_value[1]).enumeration.name
        else
          old_value = old_new_value[0] && !foreign_key_value[attribute].nil? ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[0]).first.name : nil
          new_value = old_new_value[1] && !old_new_value[1].eql?('') ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[1]).first.name : ''
        end
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      JournalDetail.create(:journal_id => self.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end
  
  def journalized_identifier_method
    if self.journalized
      return self.journalized.string_identifier_method
    end
  end
  
  def identifier_value
    if self.journalized_identifier
      return self.journalized_identifier
    else
      method = self.journalized_identifier_method
      if method.nil?
        return self.journalized_id
      else
        return self.journalized.send(self.journalized_identifier_method)
      end
    end
  end
end
