# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestUomPermission < Minitest::Test
    include Crossbeams::Responses
    include GeneralFactory

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        uom_type_id: 1,
        uom_code: Faker::Lorem.unique.word
      }
      MasterfilesApp::Uom.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::Uom.call(:create)
      assert res.success, 'Should always be able to create a uom'
    end

    def test_edit
      MasterfilesApp::UomRepo.any_instance.stubs(:find_uom).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Uom.call(:edit, 1)
      assert res.success, 'Should be able to edit a uom'
    end

    def test_delete
      MasterfilesApp::UomRepo.any_instance.stubs(:find_uom).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::Uom.call(:delete, 1)
      assert res.success, 'Should be able to delete a uom'
    end
  end
end
