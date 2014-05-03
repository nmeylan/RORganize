# Author: Nicolas
# Date: 03/05/2014
# Encoding: UTF-8
# File: version_test.rb
require 'test/unit'

class VersionTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @version = Version.new({name: 'New version', description: '', start_date: '03/05/2014', target_date: '', project_id: 1})
    @project = Project.find_by_id(1)
    @version.save
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @version.destroy
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
    @version.change_position(@project, 'dec')
    @version.change_position(@project, 'dec')
    @version.reload
    assert_equal old_position - 2, @version.position
  end

  test 'Increment position must fail' do
    old_position = @version.position
    @version.change_position(@project, 'inc')
    @version.reload
    assert_equal old_position, @version.position
  end

  test 'Crap param position must fail' do
    old_position = @version.position
    @version.change_position(@project, 'crap')
    @version.reload
    assert_equal old_position, @version.position
  end
end