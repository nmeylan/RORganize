# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki_page.rb
class WikiPage < RorganizeActiveRecord
  #Class variables
  assign_journalized_properties({'title' => 'Title',
      'content' => 'Content'})
  assign_foreign_keys({})
  assign_journalized_icon('/assets/document.png')
  #Slug
  extend FriendlyId
  friendly_id :title, use: :slugged
  #Triggers
  before_create :inc_position
  after_destroy :dec_position,:destroy_journal
  after_create :create_journal 
  after_update :update_journal
  #Relations
  has_one :wiki_home_page, :class_name => 'Wiki', :foreign_key => 'home_page_id', :dependent => :nullify
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :wiki, :class_name => 'Wiki', :foreign_key => 'wiki_id'
  belongs_to :parent, :class_name => 'WikiPage'
  has_many :sub_pages, :class_name => 'WikiPage', :foreign_key => 'parent_id', :dependent => :nullify
 
  validates :title, :presence => true, :uniqueness => true
  
  def inc_position
    self.position = self.class.where(:parent_id => self.parent_id).count('*')
  end
  
  def dec_position
    pages = self.class.where('parent_id = ? AND id <> ? AND position > ?', self.parent_id, self.id, self.position)
    pages.each do |wiki_page|
      p = (wiki_page.read_attribute('position') -1)
      wiki_page.update_attributes(:position => p)
    end
  end
  
  def project_id
    return self.wiki.project_id
  end
end
