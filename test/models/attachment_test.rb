# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: attachment_test.rb
require 'test_helper'
class AttachmentTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @attachment = Attachment.create(name: 'File test',
                                    attachable_id: @project.id, attachable_type: 'Project')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @attachment.destroy
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

  test 'any image file is attached and thumbnailed' do
    assert_nil @attachment.file.path(:original)
    assert_nil @attachment.file.path(:thumb)

    @attachment.file = File.new("#{Rails.root}/test/fixtures/files/rorganize_logo.png")
    assert @attachment.save, @attachment.errors.messages

    assert_processed :original
    assert_processed :thumb
  end

  test 'any non-image file is attached but not thumbnailed' do
    assert_nil @attachment.file.path(:original)

    @attachment.file = File.new("#{Rails.root}/test/fixtures/issues.yml")
    assert @attachment.save, @attachment.errors.messages

    assert_processed :original
    assert_not_processed :thumb
  end

  test "should not save attachment when file is bigger than 1mo" do
    assert_nil @attachment.file.path(:original)

    @attachment.file = File.new("#{Rails.root}/test/fixtures/files/fat_koala.jpg")
    assert_not @attachment.save, 'attachment has been saved'
  end

  private

  def assert_processed(style)
    path = @attachment.file.path(style)
    assert File.exist?(path), "#{style} not processed"
  end

  def assert_not_processed(style)
    path = @attachment.file.path(style)
    assert_not File.exist?(path), "#{style} unduly processed"
  end
end
