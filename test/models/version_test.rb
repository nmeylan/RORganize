# Author: Nicolas
# Date: 03/05/2014
# Encoding: UTF-8
# File: version_test.rb
require 'test_helper'

class VersionTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = Project.create(name: 'Rorganize test')
    @version = Version.create({name: 'New version', description: '', start_date: '03/05/2014', target_date: '', project_id: 1})
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @version.destroy
  end

  test 'caption should be equal to name' do
    assert_equal @version.name, @version.caption
  end

  test 'permit attributes should contains' do
    assert_equal [:name, :target_date, :description, :start_date, :is_done], Version.permit_attributes
  end

  test 'it can be closed' do
    today = Date.new(2012, 12, 22)
    version = Version.create(name: 'Version test', start_date: '2012-12-01', project_id: @project.id)
    Date.stub :today, today do
      assert_not version.closed?, 'Version is closed'

      version.target_date = '2012-12-23'
      version.save
      assert_not version.closed?, 'Version is closed'

      version.target_date = '2012-12-22'
      version.save
      assert_not version.closed?, 'Version is closed'

      version.target_date = '2012-12-21'
      version.save
      assert version.closed?, 'Version is opened'

    end
  end

  test 'it has issues count' do
    version = Version.create(name: 'Version test', start_date: '2012-12-01', project_id: @project.id)
    Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id, version_id: version.id)
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug2', status_id: 1, project_id: @project.id)

    assert_equal 1, version.issues_count
    issue1.version = version
    issue1.save
    version.reload
    assert_equal 2, version.issues_count
  end

  test 'it update issues start date and slide due date when version start date is updated' do
    version = Version.create(name: 'Version test', start_date: '2012-12-01', project_id: @project.id)
    issue1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id, version_id: version.id, start_date: '2012-12-01', due_date: '2012-12-15')
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug2', status_id: 1, project_id: @project.id, version_id: version.id, start_date: '2012-12-01', due_date: '2012-12-15')
    issue3 = Issue.create(tracker_id: 1, subject: 'Bug3', status_id: 1, project_id: @project.id, version_id: version.id, start_date: '2012-12-03', due_date: '2012-12-19')
    issue4 = Issue.create(tracker_id: 1, subject: 'Bug4', status_id: 1, project_id: @project.id, version_id: version.id, start_date: '2012-12-20', due_date: '2012-12-30')
    issues = [issue1, issue2, issue3, issue4]

    version.start_date = Date.new(2012, 11, 01)
    assert version.save, version.errors.messages
    issues.each(&:reload)
    assert_equal Date.new(2012, 12, 01), issue1.start_date
    assert_equal Date.new(2012, 12, 01), issue2.start_date
    assert_equal Date.new(2012, 12, 03), issue3.start_date
    assert_equal Date.new(2012, 12, 20), issue4.start_date
    assert_equal Date.new(2012, 12, 15), issue1.due_date
    assert_equal Date.new(2012, 12, 15), issue2.due_date
    assert_equal Date.new(2012, 12, 19), issue3.due_date
    assert_equal Date.new(2012, 12, 30), issue4.due_date

    version.start_date = Date.new(2012, 12, 02)
    assert version.save, version.errors.messages
    issues.each(&:reload)
    assert_equal Date.new(2012, 12, 02), issue1.start_date
    assert_equal Date.new(2012, 12, 02), issue2.start_date
    assert_equal Date.new(2012, 12, 03), issue3.start_date
    assert_equal Date.new(2012, 12, 20), issue4.start_date
    assert_equal Date.new(2012, 12, 15), issue1.due_date
    assert_equal Date.new(2012, 12, 15), issue2.due_date
    assert_equal Date.new(2012, 12, 19), issue3.due_date
    assert_equal Date.new(2012, 12, 30), issue4.due_date

    version.start_date = Date.new(2012, 12, 01)
    assert version.save, version.errors.messages
    issues.each(&:reload)
    assert_equal Date.new(2012, 12, 02), issue1.start_date
    assert_equal Date.new(2012, 12, 02), issue2.start_date
    assert_equal Date.new(2012, 12, 03), issue3.start_date
    assert_equal Date.new(2012, 12, 20), issue4.start_date
    assert_equal Date.new(2012, 12, 15), issue1.due_date
    assert_equal Date.new(2012, 12, 15), issue2.due_date
    assert_equal Date.new(2012, 12, 19), issue3.due_date
    assert_equal Date.new(2012, 12, 30), issue4.due_date

    version.start_date = Date.new(2012, 12, 17)
    assert version.save, version.errors.messages
    issues.each(&:reload)
    assert_equal Date.new(2012, 12, 17), issue1.start_date
    assert_equal Date.new(2012, 12, 17), issue2.start_date
    assert_equal Date.new(2012, 12, 17), issue3.start_date
    assert_equal Date.new(2012, 12, 20), issue4.start_date
    assert_equal nil, issue1.due_date
    assert_equal nil, issue2.due_date
    assert_equal Date.new(2012, 12, 19), issue3.due_date
    assert_equal Date.new(2012, 12, 30), issue4.due_date
  end

  test 'Increment position on version create' do
    versions = Version.where(project_id: 1).order('position ASC')
    i = 1
    #Check uniq position
    versions.each do |version|
      assert_equal i, version.position
      i += 1
    end
    #Check last enumeration created equal last index
    assert_equal @version.position, i - 1
  end

  test 'Decrement position' do
    old_position = @version.position
    @version.change_position('dec')
    @version.change_position('dec')
    @version.reload
    assert_equal old_position - 2, @version.position
  end

  test 'Increment position must fail' do
    old_position = @version.position
    @version.change_position('inc')
    @version.reload
    assert_equal old_position, @version.position
  end

  test 'Crap param position must fail' do
    old_position = @version.position
    @version.change_position('crap')
    @version.reload
    assert_equal old_position, @version.position
  end

  test 'it should not be saved when start date is lesser than due date' do
    version = Version.new({name: 'New version', description: '', start_date: '2012-12-01', target_date: '2012-11-30', project_id: 1})
    assert_not version.save
    version.target_date = '2012-12-01'
    assert_not version.save

    version.target_date = '2012-12-02'
    assert version.save
  end

  test 'set position after destroy' do
    project = Project.create(name: 'Rorganize test version')
    version = Version.new({name: 'New version', description: '', start_date: '2012-12-01', project_id: project.id})
    version1 = Version.new({name: 'New version 1', description: '', start_date: '2012-12-01', project_id: project.id})
    version2 = Version.new({name: 'New version 2', description: '', start_date: '2012-12-01', project_id: project.id})

    assert version.save, version.errors.messages
    assert version1.save, version1.errors.messages
    assert version2.save, version2.errors.messages
    assert version1.position > version.position
    assert version2.position > version1.position
    version2.change_position('dec')
    version2.reload
    version1.reload
    assert version2.position < version1.position
    old_version1_position = version1.position
    old_version2_position = version2.position

    version.destroy
    version1.reload
    version2.reload
    assert_equal old_version1_position - 1, version1.position
    assert_equal old_version2_position - 1, version2.position
  end
end