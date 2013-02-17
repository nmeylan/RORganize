class Project < ActiveRecord::Base
  has_many :members, :class_name => 'Member'
  has_and_belongs_to_many :trackers, :class_name => 'Tracker'
  has_and_belongs_to_many :versions, :class_name => 'Version', :include => [:issues]
  has_many :categories, :class_name => 'Category'
  has_many :issues, :class_name => 'Issue'
  validates :name, :identifier, :presence => true
  validates :name, :length => {
    :maximum   => 255,
    :tokenizer => lambda { |str| str.scan(/\w+/) },
    :too_long  => "must have at most 255 words"
  }
end
