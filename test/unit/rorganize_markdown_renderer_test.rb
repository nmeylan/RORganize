# Author: Nicolas Meylan
# Date: 07.08.14
# Encoding: UTF-8
# File: rorganize_markdown_renderer_test.rb

require 'test_helper'
class RorganizeMarkdownRendererTest < ActiveSupport::TestCase
  include ApplicationHelper

  def setup
    @text = <<EOF
- k
- l
 - i

- [x] task complete b
- [ ] task uncomplete a

some text in **bold**

- [ ] task uncomplete c
- [x] task complete d
EOF
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end

  test 'markdown renderer' do
    p markdown_to_html(@text)
  end
end