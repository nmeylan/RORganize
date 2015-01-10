# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: journal_detail_test.rb
require 'test_helper'

class JournalDetailTest < ActiveSupport::TestCase

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

  test 'it delete_all_orphans' do
    orphan = JournalDetail.create(journal_id: 666, property: 'Assigned to', property_key: :assigned_to_id,
                         old_value: nil, value: 'Nicolas Meylan')
    orphan1 = JournalDetail.create(journal_id: 667, property: 'Assigned to', property_key: :assigned_to_id,
                         old_value: nil, value: 'Nicolas Meylan')
    orphan2 = JournalDetail.create(journal_id: 666, property: 'Assigned to', property_key: :assigned_to_id,
                         old_value: nil, value: 'Nicolas Meylan')

    journal = Journal.create(journalizable_type: 'Issue', journalizable_id: 666, action_type: 'created',
                             project_id: 666, journalizable_identifier: 'aa', created_at: Time.new(2012, 10, 21))
    non_orphan = JournalDetail.create(journal_id: journal.id, property: 'Assigned to', property_key: :assigned_to_id,
                                      old_value: nil, value: 'Nicolas Meylan')
    assert orphan.id
    assert orphan1.id
    assert orphan2.id
    assert non_orphan.id

    JournalDetail.delete_all_orphans(666)

    assert_raise(ActiveRecord::RecordNotFound) { orphan.reload }
    assert_raise(ActiveRecord::RecordNotFound) { orphan1.reload }
    assert_raise(ActiveRecord::RecordNotFound) { orphan2.reload }
    assert non_orphan.reload
  end

end