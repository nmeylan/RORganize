# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: attachment_test.rb
require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "permit attributes should contains" do
    expectation = [:file, :tempfile, :original_filename, :content_type, :headers, :form_data, :name]
    assert_match_array expectation, Attachment.permit_attributes
  end

  test "it should display an icon depending on content type" do
    attachment = Attachment.new(file_content_type: 'application/pdf')
    assert_equal 'file-pdf', attachment.icon_type

    attachment.file_content_type = 'text/html'
    assert_equal 'file-media', attachment.icon_type
  end

  test 'it should skip image magick process when file is not an image' do
    attachment = Attachment.new(file_content_type: 'application/pdf')
    assert_not attachment.should_process?

    attachment.file_content_type = 'text/html'
    assert_not attachment.should_process?

    attachment.file_content_type = 'image/jpeg'
    assert attachment.should_process?

    attachment.file_content_type = 'image/svg+xml'
    assert attachment.should_process?
  end
end