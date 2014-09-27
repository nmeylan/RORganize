# Author: Nicolas Meylan
# Date: 29.07.14
# Encoding: UTF-8
# File: activities.rb

class Activities
  # This object combine both Journals and Comments. It is used to display :
  # #User activities
  # #Project activities
  attr_reader :content
  # @param [Enumerable] journals an active record collection of Journal.
  # @param [Enumerable] comments an active record collection of Comment.
  def initialize(journals, comments = [])
    @journals = journals.any? ? journals.decorate : journals
    @comments = comments.any? ? comments.decorate : comments
    @content = Hash.new { |h, k| h[k] = {} } #e.g  {date: {type_id: [journalizable, journalizable, comment, journalizable]}}
    crunch_data
  end

  # @param [Date] date.
  # @param [String] polymorphic_identifier the identifier of the object.
  # @return [Array] activities of a specific object for a given date.
  def content_for(date, polymorphic_identifier)
    @content[date][polymorphic_identifier]
  end

  private
  # This method build a hash with the following structure : {date: {type_id: [journalizable, journalizable, comment, journalizable]}}
  def crunch_data
    tmp_hash = Hash.new { |h, k| h[k] = {} }
    fruit_salad = @journals | @comments
    fruit_salad.sort { |x, y| y.created_at <=> x.created_at }.each do |element|
      s = element.created_at.to_date
      tmp_hash[s][element.polymorphic_identifier] ||= []
      tmp_hash[s][element.polymorphic_identifier] << element
    end
    tmp_hash.each do |date, elements_hash|
      elements_hash.each do |polymorphic_identifier, elements|
        @content[date][polymorphic_identifier] = elements.compact.sort { |x, y| y.created_at <=> x.created_at }
      end
    end
  end
end