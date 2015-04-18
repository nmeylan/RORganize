# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki.rb

class Wiki < ActiveRecord::Base
  include SmartRecords
  #Relations
  belongs_to :home_page, class_name: 'WikiPage', foreign_key: :home_page_id
  has_many :pages, class_name: 'WikiPage', foreign_key: :wiki_id, dependent: :delete_all
  belongs_to :project
  #Validations
  validates :project_id, uniqueness: true, presence: true

  def caption
    'Wiki'
  end

  # @param [Hash] organization : a hash with the following structure
  # {page_id => {'parent_id' => String, 'position' => String}}
  # e.g : {"1"=>{"parent_id"=>"null", "position"=>"0"},
  #         "2"=>{"parent_id"=>"null", "position"=>"1"}, "3"=>{"parent_id"=>"2", "position"=>"0"}
  #       }
  def self.organize_pages(organization)
    page_ids = organization.keys
    wiki_pages = WikiPage.where(id: page_ids)
    parent = nil
    wiki_pages.each do |page|
      page_id_key = page.id.to_s
      parent = organization[page_id_key][:parent_id]
      if parent.eql?('null')
        organization[page_id_key][:parent_id] = nil
      end
      page.update_attributes(organization[page_id_key])
    end
  end
end