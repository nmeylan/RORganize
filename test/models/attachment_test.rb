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
end