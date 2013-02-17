# Author: Nicolas Meylan
# Date: 2 août 2012
# Encoding: UTF-8
# File: remote_link_renderer.rb

class RemoteLinkRenderer < WillPaginate::ActionView::LinkRenderer
  private
  def link(text, target, attributes = {})
    attributes["data-remote"] = true
    super
  end
end
