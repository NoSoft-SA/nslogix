# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestTreatmentPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        treatment_type_id: 12,
        treatment_code: Faker::Lorem.unique.word,
        description: 'ABC',
        active: true,
        treatment_type_code: 'ABC'
      }
      MasterfilesApp::Treatment.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::Treatment.call(:create)
      assert res.success, 'Should always be able to create a treatment'
    end

    def test_edit
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Treatment.call(:edit, 1)
      assert res.success, 'Should be able to edit a treatment'
    end

    def test_delete
      MasterfilesApp::FruitRepo.any_instance.stubs(:find_treatment).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Treatment.call(:delete, 1)
      assert res.success, 'Should be able to delete a treatment'
    end
  end
end
