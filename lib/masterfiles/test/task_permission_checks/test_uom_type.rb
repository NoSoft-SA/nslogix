# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestUomTypePermission < Minitest::Test
    include Crossbeams::Responses
    include GeneralFactory

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        uom_type_code: Faker::Lorem.unique.word
      }
      MasterfilesApp::UomType.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::UomType.call(:create)
      assert res.success, 'Should always be able to create a uom_type'
    end

    def test_edit
      MasterfilesApp::UomRepo.any_instance.stubs(:find_uom_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::UomType.call(:edit, 1)
      assert res.success, 'Should be able to edit a uom_type'
    end

    def test_delete
      MasterfilesApp::UomRepo.any_instance.stubs(:find_uom_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::UomType.call(:delete, 1)
      assert res.success, 'Should be able to delete a uom_type'
    end
  end
end
