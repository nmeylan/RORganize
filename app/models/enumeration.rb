class Enumeration < ActiveRecord::Base
  include Rorganize::SmartRecords

  before_save :inc_position
  after_destroy :dec_position_on_destroy
  validates :name, :presence => true, :length => 2..255

  def caption
    self.name
  end

  def self.permit_attributes
    [:opt, :name, :position]
  end

  def inc_position
    count = Enumeration.select('*').where(['opt = ?',self.opt]).count
    self.position = count + 1
  end


  def dec_position_on_destroy
    position = self.position
    Enumeration.where("position > #{position} AND opt = 'ISTS'").update_all 'position = position - 1'
  end
end
