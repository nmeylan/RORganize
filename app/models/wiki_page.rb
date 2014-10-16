# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki_page.rb
class WikiPage < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  #Class variables
  exclude_attributes_from_journal(:slug)
  #Slug
  extend FriendlyId
  friendly_id :title, use: :slugged
  #Triggers
  before_create :inc_position
  after_destroy :dec_position, :destroy_journal
  #Relations
  has_one :wiki_home_page, class_name: 'Wiki', foreign_key: 'home_page_id', dependent: :nullify
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :wiki, class_name: 'Wiki', foreign_key: 'wiki_id'
  belongs_to :parent, class_name: 'WikiPage'
  has_many :sub_pages, class_name: 'WikiPage', foreign_key: 'parent_id', dependent: :nullify

  validates :title, presence: true

  def caption
    self.title
  end

  def self.permit_attributes
    [:parent_id, :title, :content]
  end

  def inc_position
    self.position = self.class.where(parent_id: self.parent_id).count('*')
  end

  def dec_position
    pages = self.class.where('parent_id = ? AND id <> ? AND position > ?', self.parent_id, self.id, self.position)
    pages.each do |wiki_page|
      p = (wiki_page.read_attribute('position') -1)
      wiki_page.update_attributes(position: p)
    end
  end

  def project_id
    self.wiki.project_id
  end

  def self.page_creation(project_id, wiki_page_params, params)
    wiki = Wiki.find_by_project_id(project_id)
    wiki_page = wiki.pages.build(wiki_page_params)
    wiki_page.author = User.current
    if wiki_page_params[:parent_id]
      wiki_page.parent = WikiPage.find_by_slug(wiki_page_params[:parent_id])
    end
    perform_creation(params, wiki, wiki_page)
  end

  private
  def self.perform_creation(params, wiki, wiki_page)
    wiki_page_success = wiki_page.save
    home_page_success = true
    if wiki_page_success
      if params[:wiki] && params[:wiki][:home_page] && wiki.home_page_id.nil?
        wiki.home_page = wiki_page
        home_page_success = wiki.save
      end
    end
    return wiki_page, wiki, wiki_page_success, home_page_success
  end
end
