# Author: Nicolas Meylan
# Date: 30.07.14
# Encoding: UTF-8
# File: history.rb

class History
  attr_reader :journals, :comments, :content

  def initialize(journals, comments = [])
    @journals = journals.decorate
    @comments = comments.decorate
    @content = []
    crunch_data if @journals.any? || @comments.any?
  end

  private
  def crunch_data
    if @journals.any?
      @journals.delete_if { |journal| journal.details.empty? }
    end
    fruit_salad = []
    fruit_salad += @journals.flatten
    fruit_salad += @comments.flatten
    @content = fruit_salad.sort { |x, y| x.created_at <=> y.created_at }
  end
end