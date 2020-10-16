# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestPalletStackTypePermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        stack_type_code: Faker::Lorem.unique.word,
        description: 'ABC',
        stack_height: 1,
        active: true
      }
      MasterfilesApp::PalletStackType.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::PalletStackType.call(:create)
      assert res.success, 'Should always be able to create a pallet_stack_type'
    end

    def test_edit
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_pallet_stack_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::PalletStackType.call(:edit, 1)
      assert res.success, 'Should be able to edit a pallet_stack_type'
    end

    def test_delete
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_pallet_stack_type).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::PalletStackType.call(:delete, 1)
      assert res.success, 'Should be able to delete a pallet_stack_type'
    end
  end
end
