# Author: Nicolas Meylan
# Date: 23.08.14
# Encoding: UTF-8
# File: anonymous_user.rb

class AnonymousUser < User
  def initialize(arg)
    super(arg)
  end

  @@instance = AnonymousUser.new({id: -666, name: 'Anonymous', slug: 'anonymous'})

  def self.instance
    return @@instance
  end

  private_class_method :new

end