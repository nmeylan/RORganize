module Rorganize
  module Helpers
    module IssuesHelper
      include IssuesHelpers::IssuesOverviewHelper
      include Rorganize::Helpers::IssuesHelpers::IssuesFilterHelper
    end
  end
end
