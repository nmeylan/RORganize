class Enumeration < ActiveRecord::Base
  include Rorganize::Models::SmartRecords

  before_create :inc_position
  after_destroy :dec_position_on_destroy
  validates :name, presence: true, length: 2..255
  validates :opt, presence: true, length: 4..4
  validate :name_uniqueness

  def caption
    self.name
  end

  def self.permit_attributes
    [:opt, :name, :position]
  end

  def inc_position
    count = Enumeration.select('*').where('opt = ?', self.opt).count
    self.position = count + 1
  end


  def dec_position_on_destroy
    Enumeration.where("position > ? AND opt = ?", self.position, self.opt).update_all 'position = position - 1'
  end

  def name_uniqueness
    count = Enumeration.where(name: self.name, opt: self.opt).where.not(id: self.id).count
    if count > 0
      errors.add(:name, 'must be uniq.')
    end
  end
end
