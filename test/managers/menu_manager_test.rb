# Author: Nicolas Meylan
# Date: 17.02.15 15:13
# Encoding: UTF-8
# File: menu_manager_test.rb
require 'test_helper'

class MenuManagerTest < ActiveSupport::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    Rorganize::Managers::MenuManager.clear_menu!(:test)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  test "it should build a new menu" do
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu, 'My menu', {controller: 'tests', action: 'my_action'}, {id: 'menu-test-my_action'})
      menu.add(:my_menu_glyph, 'My menu with glyph', {controller: 'tests', action: 'my_action_glyph'}, {id: 'menu-test-my_menu_glyph', glyph: 'test'})
    end
    test_menu_creation
  end

  test "it should append menu item if the menu already exists" do
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu, 'My menu', {controller: 'tests', action: 'my_action'}, {id: 'menu-test-my_action'})
    end
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu_glyph, 'My menu with glyph', {controller: 'tests', action: 'my_action_glyph'}, {id: 'menu-test-my_menu_glyph', glyph: 'test'})
    end
    test_menu_creation
  end

  test "it should put the last menu before the first" do
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'tests', action: 'my_action_0'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'tests', action: 'my_action_1'}, {id: 'menu-test-my_action_1'})
      menu.add(:my_menu_2, 'My menu 2', {controller: 'tests', action: 'my_action_2'}, {id: 'menu-test-my_action_2', glyph: 'test', before: :my_menu_0})
    end
    menu = Rorganize::Managers::MenuManager.menu(:test)
    assert_equal :my_menu_2, menu.menu_items[0].name
    assert_equal :my_menu_0, menu.menu_items[1].name
    assert_equal :my_menu_1, menu.menu_items[2].name
  end

  test "it should put the last menu before the second" do
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'tests', action: 'my_action_0'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'tests', action: 'my_action_1'}, {id: 'menu-test-my_action_1'})
      menu.add(:my_menu_2, 'My menu 2', {controller: 'tests', action: 'my_action_2'}, {id: 'menu-test-my_action_2', glyph: 'test', before: :my_menu_0})
      menu.add(:my_menu_3, 'My menu 3', {controller: 'tests', action: 'my_action_3'}, {id: 'menu-test-my_action_3', glyph: 'test', before: :my_menu_1})
    end
    menu = Rorganize::Managers::MenuManager.menu(:test)
    assert_equal :my_menu_2, menu.menu_items[0].name
    assert_equal :my_menu_0, menu.menu_items[1].name
    assert_equal :my_menu_3, menu.menu_items[2].name
    assert_equal :my_menu_1, menu.menu_items[3].name
  end

  test "it should put the first menu after the last" do
    Rorganize::Managers::MenuManager.map :test do |menu|
      menu.add(:my_menu_0, 'My menu 0', {controller: 'tests', action: 'my_action_0'}, {id: 'menu-test-my_action_0'})
      menu.add(:my_menu_1, 'My menu 1', {controller: 'tests', action: 'my_action_1'}, {id: 'menu-test-my_action_1'})
      menu.add(:my_menu_2, 'My menu 2', {controller: 'tests', action: 'my_action_2'}, {id: 'menu-test-my_action_2', glyph: 'test', after: :my_menu_0})
    end
    menu = Rorganize::Managers::MenuManager.menu(:test)
    assert_equal :my_menu_0, menu.menu_items[0].name
    assert_equal :my_menu_2, menu.menu_items[1].name
    assert_equal :my_menu_1, menu.menu_items[2].name
  end

  test "it should raise and error when position is set after or before an undefined menu" do
    assert_raises(ArgumentError) do
      Rorganize::Managers::MenuManager.map :test do |menu|
        menu.add(:my_menu_0, 'My menu 0', {controller: 'tests', action: 'my_action_0'}, {id: 'menu-test-my_action_0', after: :my_menu_1})
        menu.add(:my_menu_1, 'My menu 1', {controller: 'tests', action: 'my_action_1'}, {id: 'menu-test-my_action_1'})
      end
    end
  end

  private
  def test_menu_creation(reversed = false)
    menu = Rorganize::Managers::MenuManager.menu(:test)
    assert_not_nil menu
    assert_equal 2, menu.menu_items.size

    first_menu_item = menu.menu_items[0]
    second_menu_item = menu.menu_items[1]

    assert_equal :my_menu, first_menu_item.name
    assert_equal 'My menu', first_menu_item.label
    assert_equal 'tests', first_menu_item.controller
    assert_equal 'my_action', first_menu_item.action

    assert_equal 'test', second_menu_item.params[:glyph]
  end
end