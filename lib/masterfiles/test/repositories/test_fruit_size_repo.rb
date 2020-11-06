# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestFruitSizeRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_basic_packs
      assert_respond_to repo, :for_select_standard_packs
      assert_respond_to repo, :for_select_standard_counts
      assert_respond_to repo, :for_select_actual_counts
      assert_respond_to repo, :for_select_fruit_size_references
    end

    def test_crud_calls
      test_crud_calls_for :basic_packs, name: :basic_pack, wrapper: BasicPack
      test_crud_calls_for :standard_packs, name: :standard_pack, wrapper: StandardPack
      test_crud_calls_for :standard_counts, name: :standard_count, wrapper: StandardCount
      test_crud_calls_for :actual_counts, name: :actual_count, wrapper: ActualCount
      test_crud_calls_for :fruit_size_references, name: :fruit_size_reference, wrapper: FruitSizeReference
    end

    private

    def repo
      FruitSizeRepo.new
    end
  end
end
