# frozen_string_literal: true

module LogisticsApp
  module PalletFactory # rubocop:disable Metrics/ModuleLength
    def create_pallet_sequence(opts = {}) # rubocop:disable Metrics/AbcSize
      pallet_id = create_pallet
      farm_id = create_farm
      puc_id = create_puc
      orchard_id = create_orchard
      cultivar_group_id = create_cultivar_group
      cultivar_id = create_cultivar
      season_id = create_season
      grade_id = create_grade
      marketing_variety_id = create_marketing_variety
      customer_variety_id = create_customer_variety
      standard_pack_id = create_standard_pack
      mark_id = create_mark
      inventory_code_id = create_inventory_code
      party_role_id = create_party_role('O', AppConst::ROLE_MARKETER)
      target_market_group_id = create_target_market_group

      default = {
        pallet_id: pallet_id,
        pallet_number: Faker::Lorem.unique.word,
        pallet_sequence_number: Faker::Number.number(digits: 4),
        farm_id: farm_id,
        puc_id: puc_id,
        orchard_id: orchard_id,
        cultivar_group_id: cultivar_group_id,
        cultivar_id: cultivar_id,
        season_id: season_id,
        grade_id: grade_id,
        marketing_variety_id: marketing_variety_id,
        customer_variety_id: customer_variety_id,
        standard_pack_id: standard_pack_id,
        marketing_org_party_role_id: party_role_id,
        packed_tm_group_id: target_market_group_id,
        mark_id: mark_id,
        inventory_code_id: inventory_code_id,
        extended_columns: BaseRepo.new.hash_for_jsonb_col({}),
        client_size_reference: Faker::Lorem.word,
        client_product_code: Faker::Lorem.word,
        treatment_ids: BaseRepo.new.array_for_db_col([1, 2, 3]),
        marketing_order_number: Faker::Lorem.word,
        carton_quantity: Faker::Number.number(digits: 4),
        exit_ref: Faker::Lorem.word,
        scrapped_at: '2010-01-01 12:00',
        nett_weight: Faker::Number.decimal,
        active: true,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00',
        production_run: Faker::Lorem.word,
        production_line: Faker::Lorem.word,
        packhouse: Faker::Lorem.word,
        pick_ref: Faker::Lorem.word,
        sell_by_code: Faker::Lorem.word,
        product_chars: Faker::Lorem.word,
        repacked_at: '2010-01-01 12:00',
        failed_otmc_results: BaseRepo.new.array_for_db_col([1, 2, 3]),
        phyto_data: Faker::Lorem.word
      }
      DB[:pallet_sequences].insert(default.merge(opts))
    end

    def create_pallet(opts = {}) # rubocop:disable Metrics/AbcSize
      edi_in_transaction_id = create_edi_in_transaction

      default = {
        edi_in_transaction_id: edi_in_transaction_id,
        pallet_number: Faker::Lorem.unique.word,
        exit_ref: Faker::Lorem.word,
        scrapped_at: '2010-01-01 12:00',
        shipped_at: '2010-01-01 12:00',
        shipped: false,
        stock_created_at: '2010-01-01 12:00',
        in_stock: false,
        inspected: false,
        govt_first_inspection_at: '2010-01-01 12:00',
        govt_reinspection_at: '2010-01-01 12:00',
        govt_inspection_passed: false,
        internal_inspection_passed: false,
        internal_inspection_at: '2010-01-01 12:00',
        internal_reinspection_at: '2010-01-01 12:00',
        phc: Faker::Lorem.word,
        intake_created_at: '2010-01-01 12:00',
        first_cold_storage_at: '2010-01-01 12:00',
        cooled: false,
        gross_weight: Faker::Number.decimal,
        nett_weight: Faker::Number.decimal,
        weight_measured_at: '2010-01-01 12:00',
        on_site_location: Faker::Lorem.word,
        consignment_note_number: Faker::Lorem.word,
        original_consignment_note_number: Faker::Lorem.word,
        inspection_point: Faker::Lorem.word,
        original_inspection_point: Faker::Lorem.word,
        carton_quantity: Faker::Number.number(digits: 4),
        allocated: false,
        allocated_at: '2010-01-01 12:00',
        reinspected: false,
        scrapped: false,
        repacked: false,
        repacked_at: '2010-01-01 12:00',
        temp_tail: Faker::Lorem.word,
        active: true,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      DB[:pallets].insert(default.merge(opts))
    end

    def create_edi_in_transaction(opts = {})
      default = {
        file_name: Faker::Lorem.unique.word,
        flow_type: Faker::Lorem.word,
        notes: Faker::Lorem.word,
        match_data: Faker::Lorem.word,
        backtrace: Faker::Lorem.word,
        complete: false,
        schema_valid: false,
        newer_edi_received: false,
        has_missing_master_files: false,
        valid: false,
        has_discrepancies: false,
        reprocessed: false,
        error_message: Faker::Lorem.word,
        created_at: '2010-01-01 12:00',
        updated_at: '2010-01-01 12:00'
      }
      DB[:edi_in_transactions].insert(default.merge(opts))
    end
  end
end
