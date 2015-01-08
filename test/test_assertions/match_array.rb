# Author: Nicolas Meylan
# Date: 08.01.15
# Encoding: UTF-8
# File: match_arrayy.rb


class MatchArray
  def initialize(expected, actual)
    @expected = expected
    @actual = actual
  end

  def match()
    return result, message
  end

  def result()
    return false unless @actual.respond_to? :to_ary
    @extra_items = difference_between_arrays(@actual, @expected)
    @missing_items = difference_between_arrays(@expected, @actual)
    @extra_items.empty? & @missing_items.empty?
  end

  def message()
    if @actual.respond_to? :to_ary
      message = "expected collection contained: #{safe_sort(@expected).inspect}\n"
      message += "actual collection contained: #{safe_sort(@actual).inspect}\n"
      message += "the missing elements were: #{safe_sort(@missing_items).inspect}\n" unless @missing_items.empty?
      message += "the extra elements were: #{safe_sort(@extra_items).inspect}\n" unless @extra_items.empty?
    else
      message = "expected an array, actual collection was #{@actual.inspect}"
    end

    message
  end


  def safe_sort(array)
    array.sort rescue array
  end

  def difference_between_arrays(array_1, array_2)
    difference = array_1.to_ary.dup
    array_2.to_ary.each do |element|
      if index = difference.index(element)
        difference.delete_at(index)
      end
    end
    difference
  end
end # MatchArray

