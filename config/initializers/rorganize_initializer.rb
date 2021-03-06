# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: rorganize_initalizer.rb
require 'rorganize'

#If true user can register to application them self. If false, an administrator have to create an account for user.
RORganize::Application.config.rorganize_allow_user_self_registration = true
#If true unregister users can access to public project as Anonymous role. If false, user have to register to access to the application.
RORganize::Application.config.rorganize_anonymous_access = true

RORganize::Application.config.enable_emails_notifications = true

#T Attachment size : range.<gigabytes|megabytes|kilobytes>
RORganize::Application.config.attachments_size = 0..1.megabytes

module WillPaginate
  module ActiveRecord
    module RelationMethods
      prepend Rorganize::Patches::WillPaginatePatch::RelationMethods
    end
  end
end
