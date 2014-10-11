# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: issue_extra_methods.rb
module Rorganize
  module Models
    module UserExtraMethods
      include Users::Authorization

    end
  end
end