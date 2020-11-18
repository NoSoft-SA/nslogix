# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LogisticsApp
  class TestPalletSequencePermission < Minitest::Test
    include Crossbeams::Responses
    include PalletFactory

    def entity(attrs = {})
      base_attrs = {
        id: 1,
        pallet_id: 1,
        pallet_number: Faker::Lorem.unique.word,
        pallet_sequence_number: 1,
        farm_id: 1,
        puc_id: 1,
        orchard_id: 1,
        cultivar_group_id: 1,
        cultivar_id: 1,
        season_id: 1,
        grade_id: 1,
        marketing_variety_id: 1,
        customer_variety_id: 1,
        standard_pack_id: 1,
        marketing_org_party_role_id: 1,
        packed_tm_group_id: 1,
        mark_id: 1,
        inventory_code_id: 1,
        extended_columns: {},
        client_size_reference: 'ABC',
        client_product_code: 'ABC',
        treatment_ids: [1, 2, 3],
        marketing_order_number: 'ABC',
        carton_quantity: 1,
        exit_ref: 'ABC',
        scrapped_at: '2010-01-01 12:00',
        nett_weight: 1.0,
        production_run: 'ABC',
        production_line: 'ABC',
        packhouse: 'ABC',
        pick_ref: 'ABC',
        sell_by_code: 'ABC',
        product_chars: 'ABC',
        repacked_at: '2010-01-01 12:00',
        failed_otmc_results: [1, 2, 3],
        phyto_data: 'ABC',
        active: true
      }
      LogisticsApp::PalletSequence.new(base_attrs.merge(attrs))
    end

    def test_create
      res = LogisticsApp::TaskPermissionCheck::PalletSequence.call(:create, entity)
      assert res.success, 'Should always be able to create a pallet_sequence'
    end

    def test_edit
      LogisticsApp::PalletRepo.any_instance.stubs(:find_pallet_sequence).returns(entity)
      res = LogisticsApp::TaskPermissionCheck::PalletSequence.call(:edit, entity(grade_id: 2))
      assert res.success, 'Should be able to edit a pallet_sequence'
    end

    def test_delete
      LogisticsApp::PalletRepo.any_instance.stubs(:find_pallet_sequence).returns(entity)
      res = LogisticsApp::TaskPermissionCheck::PalletSequence.call(:delete, entity)
      assert res.success, 'Should be able to delete a pallet_sequence'
    end
  end
end
