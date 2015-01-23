# Author: Nicolas Meylan
# Date: 23.01.15 15:33
# Encoding: UTF-8
# File: record_not_found_tests.rb
module Rorganize
  module RecordNotFoundTests
    UNDEFINED_ID = 66948234

    def test_should_get_record_not_found_on_edit
      should_get_404_on(:get_with_permission, :edit, id: UNDEFINED_ID) if @controller.respond_to?(:edit)
    end

    def test_should_get_record_not_found_on_show
      should_get_404_on(:get_with_permission, :show, id: UNDEFINED_ID) if @controller.respond_to?(:show)
    end

    def test_should_get_record_not_found_on_update
      should_get_404_on(:patch_with_permission, :update, id: UNDEFINED_ID) if @controller.respond_to?(:update)
    end

    def test_should_get_record_not_found_on_destroy
      should_get_404_on(:delete_with_permission, :destroy, id: UNDEFINED_ID) if @controller.respond_to?(:destroy)
    end
  end
end