# frozen_string_literal: true

module EdiApp
  class PsInRepo < EdiInRepo
    def time_from_date_val(date)
      return nil if date.nil?

      Time.new(date[0, 4], date[4, 2], date[6, 3])
    end

    def time_from_date_and_time(date, time)
      return nil if date.nil? || time.nil?

      Time.new(date[0, 4], date[4, 2], date[6, 3], *time.split(':'))
    end

    def get_masterfile_id(table_name, args)
      id = get_variant_id(table_name, args)
      return id unless id.nil?

      @missing_masterfiles << [{ table_name: table_name, args: args }]
      nil
    end

    def ps_in_row(sequence) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      @missing_masterfiles = []
      originally_inspected_at = time_from_date_val(sequence[:orig_inspec_date])
      inspected_at = time_from_date_val(sequence[:inspec_date])
      intake_created_at = time_from_date_val(sequence[:intake_date])
      weight_measured_at = time_from_date_and_time(sequence[:weighing_date], sequence[:weighing_time])
      transaction_at = time_from_date_val(sequence[:tran_date])

      pallet_sequence = {}
      pallet_sequence[:carton_quantity] = sequence[:ctn_qty].to_i
      pallet_sequence[:cooled] = false
      pallet_sequence[:created_at] = intake_created_at
      pallet_sequence[:cultivar_group_id] = get_masterfile_id(:cultivar_groups, cultivar_group_code: sequence[:cultivar_group])
      pallet_sequence[:cultivar_id] = get_masterfile_id(:cultivars, cultivar_code: sequence[:cultivar_code])
      pallet_sequence[:depot_id] = get_masterfile_id(:depots, depot_code: sequence[:original_depot])
      pallet_sequence[:depot_pallet] = true
      pallet_sequence[:edi_in_consignment_note_number] = sequence[:cons_no]
      pallet_sequence[:edi_in_inspection_point] = sequence[:inspect_pnt]
      pallet_sequence[:edi_in_transaction_id] = sequence[:edi_in_transaction_id]
      pallet_sequence[:govt_first_inspection_at] = originally_inspected_at
      pallet_sequence[:govt_inspection_passed] = !inspected_at.nil?
      pallet_sequence[:govt_reinspection_at] = inspected_at if originally_inspected_at != inspected_at
      pallet_sequence[:grade_id] = get_masterfile_id(:grades, grade_code: sequence[:grade])
      pallet_sequence[:gross_weight] =  sequence[:pallet_gross_mass]
      pallet_sequence[:gross_weight_measured_at] = weight_measured_at
      pallet_sequence[:in_stock] = true
      pallet_sequence[:inspected] = !originally_inspected_at.nil? || !inspected_at.nil?
      pallet_sequence[:intake_created_at] = intake_created_at
      pallet_sequence[:inventory_code_id] = get_masterfile_id(:inventory_codes, inventory_code: sequence[:inventory_code])
      pallet_sequence[:mark_id] = get_masterfile_id(:marks, mark_code: sequence[:mark])
      pallet_sequence[:marketing_org_party_role_id] = MasterfilesApp::PartyRepo.new.find_party_role_from_org_code(sequence[:orgzn], AppConst::ROLE_MARKETER)
      pallet_sequence[:marketing_variety_id] = get_masterfile_id(:marketing_varieties, marketing_variety_code: sequence[:variety])
      pallet_sequence[:packed_tm_group_id] = get_masterfile_id(:target_market_groups, target_market_group_name: sequence[:target_market])
      pallet_sequence[:pallet_number] = sequence[:sscc]
      pallet_sequence[:pallet_sequence_number] = sequence[:sequence_number]
      pallet_sequence[:palletized] = true
      pallet_sequence[:palletized_at] = intake_created_at
      pallet_sequence[:phc] = sequence[:packh_code]
      pallet_sequence[:pick_ref] = sequence[:pick_ref]
      pallet_sequence[:product_chars] = sequence[:prod_char]
      pallet_sequence[:puc_id] = get_masterfile_id(:pucs, puc_code: sequence[:farm])
      pallet_sequence[:farm_id] = get_value(:farms_pucs, :farm_id, puc_id: pallet_sequence[:puc_id])
      pallet_sequence[:orchard_id] = get_masterfile_id(:orchards, orchard_code: sequence[:orchard], puc_id: pallet_sequence[:puc_id])
      pallet_sequence[:reinspected] = inspected_at != originally_inspected_at
      pallet_sequence[:season_id] = MasterfilesApp::CalendarRepo.new.get_season_id(pallet_sequence[:cultivar_id], inspected_at || transaction_at)
      pallet_sequence[:sell_by_code] = sequence[:sellbycode]
      pallet_sequence[:size_reference_id] = get_masterfile_id(:size_references, size_reference: sequence[:size_count])
      pallet_sequence[:standard_pack_id] = get_masterfile_id(:standard_packs, standard_pack_code: sequence[:pack])
      pallet_sequence[:stock_created_at] = intake_created_at || inspected_at || Time.now
      pallet_sequence[:temp_tail] = sequence[:temp_device_id]
      pallet_sequence[:weight_measured_at] = weight_measured_at
      return OpenStruct.new(success: true, instance: pallet_sequence, errors: [], message: 'Passed') if @missing_masterfiles.empty?

      OpenStruct.new(success: false, instance: pallet_sequence, errors: @missing_masterfiles.uniq, message: 'Missing Masterfiles')
    end
  end
end
