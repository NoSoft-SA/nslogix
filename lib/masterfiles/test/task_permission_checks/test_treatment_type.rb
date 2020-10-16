# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTreatmentTypePermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        treatment_type_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true
      }
      MasterfilesApp::TreatmentType.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::TreatmentType.call(:create)
      assert res.success, 'Should always be able to create a treatment_type'
    end

    def test_edit
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::TreatmentType.call(:edit, 1)
      assert res.success, 'Should be able to edit a treatment_type'
    end

    def test_delete
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::TreatmentType.call(:delete, 1)
      assert res.success, 'Should be able to delete a treatment_type'
    end
  end
end
