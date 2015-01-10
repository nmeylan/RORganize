# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: preference_test.rb
require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase

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

  test "it has keys for notification preferences" do
    expectation = {'notification_watcher_in_app' => 0, 'notification_watcher_email' => 1,
                   'notification_participant_in_app' => 2, 'notification_participant_email' => 3}
    assert_equal expectation, Preference.notification_keys
  end
end