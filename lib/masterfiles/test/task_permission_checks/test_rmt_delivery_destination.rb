# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestRmtDeliveryDestinationPermission < Minitest::Test
    include Crossbeams::Responses

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        delivery_destination_code: 'ABC',
        description: 'ABC',
        active: true
      }
      MasterfilesApp::RmtDeliveryDestination.new(base_attrs.merge(attrs))
    end

    def test_create
      res = MasterfilesApp::TaskPermissionCheck::RmtDeliveryDestination.call(:create)
      assert res.success, 'Should always be able to create a rmt_delivery_destination'
    end

    def test_edit
      MasterfilesApp::RmtDeliveryDestinationRepo.any_instance.stubs(:find_rmt_delivery_destination).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::RmtDeliveryDestination.call(:edit, 1)
      assert res.success, 'Should be able to edit a rmt_delivery_destination'
    end

    def test_delete
      MasterfilesApp::RmtDeliveryDestinationRepo.any_instance.stubs(:find_rmt_delivery_destination).returns(entity)
      res = MasterfilesApp::TaskPermissionCheck::RmtDeliveryDestination.call(:delete, 1)
      assert res.success, 'Should be able to delete a rmt_delivery_destination'
    end
  end
end
