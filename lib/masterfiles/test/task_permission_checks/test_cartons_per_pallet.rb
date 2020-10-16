# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestCartonsPerPalletPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        description: Faker::Lorem.unique.word,
        pallet_format_id: 1,
        basic_pack_id: 1,
        cartons_per_pallet: 1,
        layers_per_pallet: 1,
        active: true,
        pallet_format_code: 'ABC',
        pallet_formats_description: 'ABC',
        basic_pack_code: 'ABC'
      }
      MasterfilesApp::CartonsPerPallet.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::CartonsPerPallet.call(:create)
      assert res.success, 'Should always be able to create a cartons_per_pallet'
    end

    def test_edit
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_cartons_per_pallet).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::CartonsPerPallet.call(:edit, 1)
      assert res.success, 'Should be able to edit a cartons_per_pallet'
    end

    def test_delete
      MasterfilesApp::PackagingRepo.any_instance.stubs(:find_cartons_per_pallet).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::CartonsPerPallet.call(:delete, 1)
      assert res.success, 'Should be able to delete a cartons_per_pallet'
    end
  end
end
