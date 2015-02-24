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

Break

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
<li>i</li>
</ul></li>
</ul>

<p>Break</p>

<ul class="task-list"><li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete b</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete a</li>
</ul>

<p>some text in <strong>bold</strong></p>

<ul class="task-list"><li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete c</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete d</li>
</ul>
</div>
EOF
    assert_equal expectation[0..-2], markdown_to_html(text),  markdown_to_html(text)
  end

  test 'it builds a task list with sub task lists' do
    text = <<EOF
- k
- l
 - i

break

- [x] task complete b
- [ ] task uncomplete a
 - [x] subtask complete a
 - [ ] subtask uncomplete b

some text in **bold**

- [ ] task uncomplete c
- [x] task complete d
EOF
    expectation = <<EOF
<div class='markdown-renderer' id=''><ul>
<li>k</li>
<li>l

<ul>
<li>i</li>
</ul></li>
</ul>

<p>break</p>

<ul class="task-list"><li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete b</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete a

<ul class="task-list"><li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">subtask complete a</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="">subtask uncomplete b</li>
</ul></li>
</ul>

<p>some text in <strong>bold</strong></p>

<ul class="task-list"><li><input type="checkbox" class="task-list-item-checkbox" disabled="">task uncomplete c</li>
<li><input type="checkbox" class="task-list-item-checkbox" disabled="" checked="">task complete d</li>
</ul>
</div>
EOF
    assert_equal expectation[0..-2], markdown_to_html(text)
  end
end