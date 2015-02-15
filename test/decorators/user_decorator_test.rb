require 'test_helper'

class UserDecoratorTest < Rorganize::Decorator::TestCase
  def setup
    @user = users(:users_002)
    @user_decorator = @user.decorate
  end

  test "it displays a link to view user when user is allowed to" do
    allow_user_to('show')
    node(@user_decorator.show_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', user_path(@user_decorator.slug)
  end

  test "it should not display a link to view user when user is not allowed to" do
    node(@user_decorator.show_link)
    assert_select 'span', 1
    assert_select 'span', text: 'James Bond'
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@user_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_user_path(@user.slug)
  end

  test "it should not display a link to edit when user is not allowed to" do
    assert_nil @user_decorator.edit_link
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@user_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', user_path(@user.slug)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @user_decorator.delete_link
  end

  test "it displays a formatted last sign in date" do
    @user.last_sign_in_at = Time.new(2012, 12, 01, 15, 40, 35)
    assert_equal 'December 1st, 2012 15:40', @user_decorator.sign_in
  end

  test "it do not display a formatted last sign in date when it is nil" do
    @user.last_sign_in_at = nil
    assert_equal '-', @user_decorator.sign_in
  end

  test "it displays a formatted current sign in date" do
    @user.current_sign_in_at = Time.new(2012, 12, 01, 15, 40, 35)
    assert_equal 'December 1st, 2012 15:40', @user_decorator.current_sign_in
  end

  test "it do not display a formatted current sign in date when it is nil" do
    @user.current_sign_in_at = nil
    assert_equal '-', @user_decorator.current_sign_in
  end

  test "it displays a formatted registration date" do
    @user.created_at = Time.new(2012, 12, 01, 15, 40, 35)
    assert_equal 'December 1st, 2012 15:40', @user_decorator.register_on
  end

  test "it displays an indicator when user is an admin" do
    @user.admin = true
    node(@user_decorator.display_is_admin)
    assert_select '.octicon-crown', 1
  end

  test "it do not display an indicator when user is not an admin" do
    @user.admin = false
    assert_nil @user_decorator.display_is_admin
  end

  test "it displays a link to user without avatar" do
    node(@user_decorator.user_link(false))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{@user.slug}"
    assert_select 'img', 0
  end

  test "it displays a link to user with avatar" do
    node(@user_decorator.user_link(true))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{@user.slug}"
    assert_select 'img', 1
  end

  test "it displays a link to user with a thumb avatar" do
    node(@user_decorator.user_avatar_link)
    assert_select 'a' do
      assert_select 'img', 1
    end
  end

  test "it displays user avatar" do
    node(@user_decorator.display_avatar)
    assert_select 'img', 1
    assert_select '.user-profile.avatar', 1
  end
end
