# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: journals_helper.rb
module Rorganize
  module Helpers
    module JournalsHelper
      include JournalsHelpers::ActivityHelper
      include JournalsHelpers::ActivityDetailsHelper
      include JournalsHelpers::ActivitySidebarHelper

    end
  end
end