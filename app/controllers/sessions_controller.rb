# Author: Nicolas
# Date: 16/11/13
# Encoding: UTF-8
# File: ${FILE_NAME}
class SessionsController < Devise::SessionsController

  def create
    super
    self.resource = User.includes(:members => :role).find_by_id(self.resource.id) if self.resource
  end

  def destroy
    super
  end

end