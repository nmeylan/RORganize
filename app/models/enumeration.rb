class Enumeration < ActiveRecord::Base
  before_save :inc_position
  validates :name, :presence => true

  def inc_position
    count = Enumeration.select("*").where(["opt = ?",self.opt]).count
    self.position = count + 1
  end
end
