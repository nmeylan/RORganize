class Changelog < ActiveRecord::Base
  belongs_to :enumeration, :class_name => 'Enumeration', :foreign_key => 'enumeration_id'
  belongs_to :project, :class_name => 'Project', :foreign_key => 'project_id'
  belongs_to :version, :class_name => 'Version',:foreign_key => 'version_id'
end
