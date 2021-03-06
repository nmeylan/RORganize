# Author: Nicolas Meylan
# Date: 01.07.14
# Encoding: UTF-8
# File: abstract_model_caption.rb

module AbstractModelCaption
  class CaptionNotImplementedError < NoMethodError
  end

  def caption
    raise CaptionNotImplementedError.new("You must override 'caption' method! in your #{self.class} model", 'Caption must be override')
  end
end