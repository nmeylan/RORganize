# Author: Nicolas Meylan
# Date: 21.01.15 09:40
# Encoding: UTF-8
# File: issue_attachable_test.rb
require 'test_helper'

class IssueAttachableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: 1)
    @attachment = Attachment.create(name: 'File test',
                                    attachable_id: @issue.id, attachable_type: 'Project')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should get an error message when attachment saving has failed" do
    assert_nil @attachment.file.path(:original)

    @attachment.file = File.new("#{Rails.root}/test/fixtures/files/fat_koala.jpg")
    @issue.attachments.build(@attachment.attributes)
    assert_not @issue.save
    assert_not_empty @issue.errors.messages[:attachment]
  end

  test "has a method to build new attachment" do
    @issue.new_attachment_attributes = [{file: File.new("#{Rails.root}/test/fixtures/files/rorganize_logo.png")}]
    assert @issue.save, @issue.errors.messages
    @attachment = @issue.attachments.first
    assert_processed :original
    assert_processed :thumb
  end

  private

  def assert_processed(style)
    path = @attachment.file.path(style)
    assert File.exist?(path), "#{style} not processed"
  end
end