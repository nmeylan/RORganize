# Author: Nicolas Meylan
# Date: 9 févr. 2013
# Encoding: UTF-8
# File: rorganize_initalizer.rb

unless $0.end_with?('rake')
  require 'rorganize'

  #If true user can register to application them self. If false, an administrator have to create an account for user.
  RORganize::Application.config.rorganize_allow_user_self_registration = false
  #If true unregister users can access to public project as Anonymous role. If false, user have to register to access to the application.
  RORganize::Application.config.rorganize_anonymous_access = true

end

