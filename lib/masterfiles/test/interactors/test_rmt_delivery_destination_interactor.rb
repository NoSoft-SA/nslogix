# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestRmtDeliveryDestinationInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::RmtDeliveryDestinationRepo)
    end

    private

    def interactor
      @interactor ||= RmtDeliveryDestinationInteractor.new(current_user, {}, {}, {})
    end
  end
end
