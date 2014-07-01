# Author: Nicolas Meylan
# Date: 01.07.14
# Encoding: UTF-8
# File: abstract_model_caption.rb

module Rorganize
  module AbstractModelCaption
    class CaptionNotImplementedError < NoMethodError
    end
    def caption
      raise CaptionNotImplementedError("You must override 'caption' method!")
    end
  end
end