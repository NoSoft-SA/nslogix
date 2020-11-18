# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LogisticsApp
  class TestPalletRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_pallets
      assert_respond_to repo, :for_select_pallet_sequences
    end

    def test_crud_calls
      test_crud_calls_for :pallets, name: :pallet, wrapper: Pallet
      test_crud_calls_for :pallet_sequences, name: :pallet_sequence, wrapper: PalletSequence
    end

    private

    def repo
      PalletRepo.new
    end
  end
end
