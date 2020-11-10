# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestStandardPackPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        standard_pack_code: Faker::Lorem.unique.word,
        description: 'ABC',
        standard_pack_label: 'ABC',
        material_mass: 1.0,
        basic_pack_id: 1,
        use_size_ref_for_edi: false,
        bin: false,
        active: true

      }
      MasterfilesApp::StandardPack.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::StandardPack.call(:create)
      assert res.success, 'Should always be able to create a standard pack'
    end

    def test_edit
      MasterfilesApp::FruitSizeRepo.any_instance.stubs(:find_standard_pack).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::StandardPack.call(:edit, 1)
      assert res.success, 'Should be able to edit a standard pack'
    end

    def test_delete
      MasterfilesApp::FruitSizeRepo.any_instance.stubs(:find_standard_pack).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::StandardPack.call(:delete, 1)
      assert res.success, 'Should be able to delete a standard pack'
    end
  end
end