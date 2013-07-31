# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki.rb

class Wiki < RorganizeActiveRecord
 
  assign_journalized_icon('/assets/wiki.png')
  #Relations
  belongs_to :home_page, :class_name => "WikiPage", :foreign_key => "home_page_id"
  has_many :pages, :class_name => "WikiPage", :foreign_key => :wiki_id, :dependent => :destroy
  belongs_to :project
  #Validations
  validates :project_id, :uniqueness => true
  #Triggers
  after_create :create_journal 
  after_destroy :destroy_journal 
end