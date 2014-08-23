# Author: Nicolas Meylan
# Date: 23.08.14
# Encoding: UTF-8
# File: anonymous_user.rb

class AnonymousUser < User
  ANON_ID = -666
  def initialize(arg)
    super(arg)
  end

  @@instance = AnonymousUser.new({id: ANON_ID, name: 'Anonymous', slug: 'anonymous'})

  def self.instance
    return @@instance
  end

  private_class_method :new

end