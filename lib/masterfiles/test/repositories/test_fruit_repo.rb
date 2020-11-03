# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestFruitRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_grades
      assert_respond_to repo, :for_select_treatment_types
      assert_respond_to repo, :for_select_treatments
      assert_respond_to repo, :for_select_inventory_codes
    end

    def test_crud_calls
      test_crud_calls_for :grades, name: :grade, wrapper: Grade
      test_crud_calls_for :treatment_types, name: :treatment_type, wrapper: TreatmentType
      test_crud_calls_for :treatments, name: :treatment, wrapper: Treatment
      test_crud_calls_for :inventory_codes, name: :inventory_code, wrapper: InventoryCode
    end

    private

    def repo
      FruitRepo.new
    end
  end
end
