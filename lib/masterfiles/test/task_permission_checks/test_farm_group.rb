# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestFarmGroupPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        owner_party_role_id: 1,
        farm_group_code: 'ABC',
        description: 'ABC',
        active: true
      }
      MasterfilesApp::FarmGroup.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::FarmGroup.call(:create)
      assert res.success, 'Should always be able to create a farm_group'
    end

    def test_edit
      MasterfilesApp::FarmRepo.any_instance.stubs(:find_farm_group).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::FarmGroup.call(:edit, 1)
      assert res.success, 'Should be able to edit a farm_group'
    end

    def test_delete
      MasterfilesApp::FarmRepo.any_instance.stubs(:find_farm_group).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::FarmGroup.call(:delete, 1)
      assert res.success, 'Should be able to delete a farm_group'
    end
  end
end
