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

  test 'it update issues start date and nullify due date when version start date is updated' do
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

  test 'it should not be saved when start date empty' do
    version = Version.new({name: 'New version', description: '', project_id: 1})
    assert_not version.save
    version.target_date = '2012-12-01'
    assert_not version.save

    version.target_date = '2012-12-02'
    version.start_date= '2012-12-01'
    assert version.save
  end

  test 'it should not be saved when name is invalid' do
    version = Version.new(description: '', project_id: 1, start_date: '2012-12-01')
    assert_not version.save
    version.name = '1'
    assert_not version.save

    version.name = generate_string_of_length(21)
    assert_not version.save

    version.name = generate_string_of_length(20)
    assert version.save

    version.name = 'Hello'
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

  test 'versions overview for a project' do
    project = Project.create(name: 'Rorganize test version')
    version = Version.create(name: 'New version', description: '', start_date: '2012-12-01', project_id: project.id, is_done: false)
    version1 = Version.create(name: 'New version 1', description: '', start_date: '2013-01-01', project_id: project.id, is_done: true)

    assert Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: project.id, version_id: version.id, done: 0).done, 0
    assert Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 6, project_id: project.id, version_id: version.id, done: 20).done, 20
    assert Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 2, project_id: project.id, version_id: version.id, done: 70).done, 70
    assert Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 2, project_id: project.id, version_id: version.id, done: 90).done, 90
    assert Issue.create(tracker_id: 1, subject: 'Closed Bug1', status_id: 3, project_id: project.id, version_id: version.id).done, 100
    assert Issue.create(tracker_id: 1, subject: 'Closed Bug1', status_id: 3, project_id: project.id, version_id: version.id).done, 100
    assert Issue.create(tracker_id: 1, subject: 'Closed Bug1', status_id: 3, project_id: project.id, version_id: version.id).done, 100

    assert Issue.create(tracker_id: 1, subject: 'Closed Bug1', status_id: 3, project_id: project.id, version_id: version1.id).done, 100
    assert Issue.create(tracker_id: 1, subject: 'Closed Bug1', status_id: 3, project_id: project.id, version_id: version1.id).done, 100

    version_issues_progress_percent = (0 + 20 + 70 + 90 + 100 + 100 + 100) / 7
    version1_issues_progress_percent = (100 + 100) / 2
    version_expectation = [version.id, 4, 3, BigDecimal.new(version_issues_progress_percent)]
    version1_expectation = [version1.id, 0, 2, BigDecimal.new(version1_issues_progress_percent)]
    version_overviews = Version.overviews(project.id)

    assert_equal 2, version_overviews.size
    assert_equal version_expectation[0], version_overviews[0][0] #version id
    assert_equal version_expectation[1], version_overviews[0][1] #version opened issues
    assert_equal version_expectation[2], version_overviews[0][2] #version closed issues
    assert_equal version_expectation[3].truncate, version_overviews[0][3].truncate #version's issues progress percent

    assert_equal version1_expectation[0], version_overviews[1][0] #version id
    assert_equal version1_expectation[1], version_overviews[1][1] #version opened issues
    assert_equal version1_expectation[2], version_overviews[1][2] #version closed issues
    assert_equal version1_expectation[3].truncate, version_overviews[1][3].truncate #version's issues progress percent

    version_overviews = Version.overviews(project.id, %Q(`versions`.`id` IN (#{project.current_versions.collect(&:id).join(',')})))

    assert_equal 1, version_overviews.size
    assert_equal version_expectation[0], version_overviews[0][0] #version id
    assert_equal version_expectation[1], version_overviews[0][1] #version opened issues
    assert_equal version_expectation[2], version_overviews[0][2] #version closed issues
    assert_equal version_expectation[3].truncate, version_overviews[0][3].truncate #version's issues progress percent

    version_overviews = Version.overviews(666, %Q(`versions`.`id` IN (#{project.current_versions.collect(&:id).join(',')})))

    assert_equal 0, version_overviews.size
  end

  test 'it should bulk edit version and issues attributes after gantt edition' do
    project = Project.create(name: 'Rorganize test version')
    version = Version.create(name: 'New version', description: '', start_date: '2012-12-01', project_id: project.id, is_done: false)

    issue1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: project.id, version_id: version.id, start_date: '2012-12-01', due_date: '2012-12-10')
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 6, project_id: project.id, version_id: version.id, start_date: '2012-12-02', due_date: '2012-12-19')
    issue3 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 2, project_id: project.id, version_id: version.id, start_date: '2012-12-03', due_date: '2012-12-08')
    issue4 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 2, project_id: project.id, version_id: version.id, start_date: '2012-12-14', due_date: '2012-12-18')
    issue5 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 3, project_id: project.id, version_id: version.id, start_date: '2012-12-19', due_date: '2012-12-21')
    issue6 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 3, project_id: project.id, version_id: version.id, start_date: '2012-12-02')
    issue7 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 3, project_id: project.id, version_id: version.id, due_date: '2012-12-20')
    issues = [issue1, issue2, issue3, issue4, issue5, issue6, issue7]

    # Start date
    assert_equal Date.new(2012, 12, 1), issue1.start_date
    assert_equal Date.new(2012, 12, 2), issue2.start_date
    assert_equal Date.new(2012, 12, 3), issue3.start_date
    assert_equal Date.new(2012, 12, 14), issue4.start_date
    assert_equal Date.new(2012, 12, 19), issue5.start_date
    assert_equal Date.new(2012, 12, 2), issue6.start_date
    assert_equal nil, issue7.start_date
    # Due dates
    assert_equal Date.new(2012, 12, 10), issue1.due_date
    assert_equal Date.new(2012, 12, 19), issue2.due_date
    assert_equal Date.new(2012, 12, 8), issue3.due_date
    assert_equal Date.new(2012, 12, 18), issue4.due_date
    assert_equal Date.new(2012, 12, 21), issue5.due_date
    assert_equal nil, issue6.due_date
    assert_equal Date.new(2012, 12, 20), issue7.due_date

    start_date = Date.new(2012, 12, 4)

    version_id_attributes_changed_hash = {
        version.id => {start_date: start_date}
    }

    Version.gantt_edit(version_id_attributes_changed_hash)
    issues.each(&:reload)

    assert_equal Date.new(2012, 12, 4), issue1.start_date
    assert_equal Date.new(2012, 12, 4), issue2.start_date
    assert_equal Date.new(2012, 12, 4), issue3.start_date
    assert_equal Date.new(2012, 12, 14), issue4.start_date
    assert_equal Date.new(2012, 12, 19), issue5.start_date
    assert_equal Date.new(2012, 12, 4), issue6.start_date
    assert_equal Date.new(2012, 12, 4), issue7.start_date
    # Due dates
    target_date = Date.new(2012, 12, 18)
    version_id_attributes_changed_hash = {
        version.id => {target_date: target_date}
    }

    Version.gantt_edit(version_id_attributes_changed_hash)
    issues.each(&:reload)
    assert_equal Date.new(2012, 12, 10), issue1.due_date
    assert_equal Date.new(2012, 12, 18), issue2.due_date
    assert_equal Date.new(2012, 12, 8), issue3.due_date
    assert_equal Date.new(2012, 12, 18), issue4.due_date
    assert_equal Date.new(2012, 12, 18), issue5.due_date
    assert_equal Date.new(2012, 12, 18), issue6.due_date
    assert_equal Date.new(2012, 12, 18), issue7.due_date
  end

  test 'it has many issues and should nullify whe it is destroyed' do
    project = Project.create(name: 'Rorganize test version')
    version = Version.create(name: 'New version', description: '', start_date: '2012-12-01', project_id: project.id, is_done: false)

    issue1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: project.id, version_id: version.id, start_date: '2012-12-01', due_date: '2012-12-10')
    issue2 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 6, project_id: project.id, version_id: version.id, start_date: '2012-12-02', due_date: '2012-12-19')
    issue3 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 2, project_id: project.id, version_id: version.id, start_date: '2012-12-03', due_date: '2012-12-08')

    assert_equal version, issue1.version
    assert_equal version, issue2.version
    assert_equal version, issue3.version

    version.destroy
    issue1.reload
    issue2.reload
    issue3.reload
    assert_equal nil, issue1.version_id
    assert_equal nil, issue2.version_id
    assert_equal nil, issue3.version_id
  end
end