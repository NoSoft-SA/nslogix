# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestPalletFormatPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        description: Faker::Lorem.unique.word,
        pallet_base_id: 1,
        pallet_stack_type_id: 1,
        pallet_base_code: 'ABC',
        stack_type_code: 'ABC'
      }
      MasterfilesApp::PalletFormat.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::PalletFormat.call(:create)
      assert res.success, 'Should always be able to create a pallet_format'
    end

    def test_edit
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_pallet_format).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::PalletFormat.call(:edit, 1)
      assert res.success, 'Should be able to edit a pallet_format'
    end

    def test_delete
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_pallet_format).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::PalletFormat.call(:delete, 1)
      assert res.success, 'Should be able to delete a pallet_format'
    end
  end
end
