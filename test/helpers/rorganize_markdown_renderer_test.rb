# Author: Nicolas Meylan
# Date: 07.08.14
# Encoding: UTF-8
# File: rorganize_markdown_renderer_test.rb

require 'test_helper'
class RorganizeMarkdownRendererTest < ActiveSupport::TestCase
  include ApplicationHelper


  test 'it builds a classic task list' do
    text = <<EOF
- k
- l
 - i

- [x] task complete b
- [ ] task uncomplete a

some text in **bold**

- [ ] task uncomplete c
- [x] task complete d
EOF
    expectation = <<EOF
<div class='markdown-renderer' id=''><ul>
<li>k</li>
<li>l

<ul>
<li>i
<ul class="task-list">
<li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete b</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete a</li>
</ul>
some text in <strong>bold</strong>
<ul class="task-list">
<li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete c</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete d</li>
</ul></li>
</ul></li>
</ul>
</div>
EOF
    assert_equal expectation[0..-2], markdown_to_html(text)
  end
end