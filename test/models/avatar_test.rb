# Author: Nicolas Meylan
# Date: 30.01.15 08:25
# Encoding: UTF-8
# File: avatar_test.rb
require 'test_helper'

class AvatarTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = users(:users_001)
    @avatar = Avatar.create(name: 'avatar',
                                    attachable_id: @user.id, attachable_type: 'User')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'any image file is attached and thumbnailed' do
    assert_nil @avatar.avatar.path(:original)
    assert_nil @avatar.avatar.path(:thumb)

    @avatar.avatar = File.new("#{Rails.root}/test/fixtures/files/avatar.png")
    assert @avatar.save, @avatar.errors.messages

    assert_processed :original
    assert_processed :thumb
  end

  test 'any file expect image file are not processed' do
    assert_nil @avatar.avatar.path(:original)
    assert_nil @avatar.avatar.path(:thumb)

    @avatar.avatar = File.new("#{Rails.root}/test/fixtures/issues.yml")
    assert_not @avatar.save, 'Avatar has been saved'

    assert_not_processed :original
    assert_not_processed :thumb
  end

  private

  def assert_processed(style)
    path = @avatar.avatar.path(style)
    assert File.exist?(path), "#{style} not processed"
  end

  def assert_not_processed(style)
    path = @avatar.avatar.path(style)
    assert_not File.exist?(path), "#{style} unduly processed"
  end
end