# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestRmtDeliveryDestinationRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_rmt_delivery_destinations
    end

    def test_crud_calls
      test_crud_calls_for :rmt_delivery_destinations, name: :rmt_delivery_destination, wrapper: RmtDeliveryDestination
    end

    private

    def repo
      RmtDeliveryDestinationRepo.new
    end
  end
end
