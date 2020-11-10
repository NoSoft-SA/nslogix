# frozen_string_literal: true

module EdiApp
  class PsIn < BaseEdiInService # rubocop:disable Metrics/ClassLength
    attr_accessor :missing_masterfiles, :pallet_number
    attr_reader :user, :repo

    def initialize(edi_in_transaction_id, file_path, logger, edi_result)
      @repo = PsInRepo.new
      @user = OpenStruct.new(user_name: 'System')
      @missing_masterfiles = []
      @pallet_number = nil
      super(edi_in_transaction_id, file_path, logger, edi_result)
    end

    def call
      # match_data_on(prepare_array_for_match(match_data))
      #
      # check_missing_masterfiles
      #
      # business_validation
      #
      # create_records

      header = edi_records.select { |rec| rec[:header].to_s == 'BH' }.to_s
      match_data_on(header)

      process_records

      check_missing_masterfiles

      failed_response('stub')
      # success_response('PS processed')
    end

    private

    def process_records
      records = edi_records.select { |rec| rec[:record_type].to_s == 'PS' }.group_by { |rec| rec[:sscc] }
      log records
      records.each do |record|
        attrs = build_attrs(record)
        sequence = find_pallet_sequence(attrs)

        if sequence.nil?
          create_pallet_sequence(attrs)
          next
        end
        update_pallet_sequence(attrs) if sequence != attrs
      end
      success_response('Processed pallets')
    end

    def create_pallet_sequence(params) # rubocop:disable Metrics/AbcSize
      repo.transaction do
        res = PalletSchema.call(params)
        return validation_failed_response(res) if res.failure?

        repo.create_with_status(:pallets, 'CREATED FROM PS', res) if find_pallet(params).nil?

        res = PalletSequenceSchema.call(params)
        return validation_failed_response(res) if res.failure?

        repo.create_with_status(:pallet_sequences, 'CREATED FROM PS', res)

        log_transaction
      end
      success_response('Created pallet')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def build_attrs(sequence) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      originally_inspected_at = repo.time_from_date_val(sequence[:orig_inspec_date])
      inspected_at = repo.time_from_date_val(sequence[:inspec_date])
      intake_created_at = repo.time_from_date_val(sequence[:intake_date])
      weight_measured_at = repo.time_from_date_and_time(sequence[:weighing_date], sequence[:weighing_time])
      transaction_at = repo.time_from_date_val(sequence[:tran_date])

      pallet = {}
      pallet[:govt_first_inspection_at] = originally_inspected_at
      pallet[:govt_reinspection_at] = inspected_at if originally_inspected_at != inspected_at
      pallet[:standard_pack_id] = repo.get_variant_id(:standard_packs, standard_pack_code: sequence[:pack])

      pallet[:size_reference_id] = repo.get_variant_id(:size_references, size_reference: sequence[:size_count])
      pallet[:puc_id] = repo.get_variant_id(:pucs, puc_code: sequence[:farm])
      pallet[:farm_id] = repo.get_value(:farms_pucs, :farm_id, puc_id: pallet[:puc_id])
      pallet[:orchard_id] = repo.get_variant_id(:orchards, orchard_code: sequence[:orchard], puc_id: pallet[:puc_id])
      pallet[:cultivar_id] = repo.get_variant_id(:cultivars, cultivar_code: sequence[:cultivar])
      pallet[:cultivar_group_id] = repo.get_variant_id(:cultivar_groups, cultivar_group_code: sequence[:cultivar_group])
      pallet[:marketing_variety_id] = repo.get_variant_id(:marketing_varieties, marketing_variety_code: sequence[:variety])
      pallet[:season_id] = MasterfilesApp::CalendarRepo.new.get_season_id(pallet[:cultivar_id], inspected_at || transaction_at)

      marketing_org_party_role_id = MasterfilesApp::PartyRepo.new.find_party_role_from_org_code(sequence[:orgzn], AppConst::ROLE_MARKETER)
      marketing_org_party_role_id = repo.find_variant_id(:marketing_party_roles, sequence[:orgzn]) if marketing_org_party_role_id.nil?
      rec[:lookup_data][:marketing_org_party_role_id] = marketing_org_party_role_id
      rec[:missing_mf][:marketing_org_party_role_id] = { mode: :direct, keys: { orgzn: sequence[:orgzn], role: AppConst::ROLE_MARKETER } } if marketing_org_party_role_id.nil?
      packed_tm_group_id = repo.find_packed_tm_group_id(sequence[:targ_mkt])
      rec[:lookup_data][:packed_tm_group_id] = packed_tm_group_id
      rec[:missing_mf][:packed_tm_group_id] = { mode: :direct, raise: false, keys: { targ_mkt: sequence[:targ_mkt] } } if packed_tm_group_id.nil?
      mark_id = repo.find_mark_id(sequence[:mark])
      rec[:lookup_data][:mark_id] = mark_id
      rec[:missing_mf][:mark_id] = { mode: :direct, raise: false, keys: { mark: sequence[:mark] } } if mark_id.nil?
      inventory_code_id = repo.find_inventory_code_id(sequence[:inv_code])
      rec[:lookup_data][:inventory_code_id] = inventory_code_id
      rec[:missing_mf][:inventory_code_id] = { mode: :direct, raise: false, keys: { inv_code: sequence[:inv_code] } } if inventory_code_id.nil?
      grade_id = repo.find_grade_id(sequence[:grade])
      rec[:lookup_data][:grade_id] = grade_id
      rec[:missing_mf][:grade_id] = { mode: :direct, keys: { grade: sequence[:grade] } } if grade_id.nil?

      rec[:lookup_data][:basic_pack_id] = parent[:lookup_data][:basic_pack_id]
      rec[:lookup_data][:standard_pack_id] = parent[:lookup_data][:standard_pack_id]
      rec[:lookup_data][:pallet_format_id] = parent[:lookup_data][:pallet_format_id]
      rec[:lookup_data][:cartons_per_pallet_id] = parent[:lookup_data][:cartons_per_pallet_id]
      {
        depot_pallet: true,
        edi_in_consignment_note_number: sequence[:cons_no],
        edi_in_transaction_id: edi_in_transaction.id,
        pallet_number: pallet_number,
        in_stock: true,
        inspected: !originally_inspected_at.nil? || !inspected_at.nil?,
        weight_measured_at: weight_measured_at,
        stock_created_at: intake_created_at || inspected_at || Time.now,
        phc: sequence[:packh_code],
        intake_created_at: intake_created_at,
        gross_weight: sequence[:pallet_gross_mass].nil? || sequence[:pallet_gross_mass].to_f.zero? ? nil : sequence[:pallet_gross_mass],
        gross_weight_measured_at: weighed_date,
        palletized: true,
        palletized_at: intake_created_at,
        created_at: intake_created_at,
        reinspected: !reinspect_at.nil?,
        govt_inspection_passed: !originally_inspected_at.nil? || !inspected_at.nil?,
        cooled: false,
        temp_tail: sequence[:temp_device_id],
        edi_in_inspection_point: sequence[:inspect_pnt],
        carton_quantity: sequence[:ctn_qty].to_i,
        pick_ref: sequence[:pick_ref],
        sell_by_code: sequence[:sellbycode],
        product_chars: sequence[:prod_char]   # ???
      }
    end

    def check_missing_masterfiles
      return if missing_masterfiles.empty?

      notes = "Missing masterfiles for #{missing_masterfiles.uniq.join(", \n")}"
      missing_masterfiles_detected(notes)
      raise Crossbeams::InfoError, 'Missing masterfiles'
    end

    def validation_failed_response(res)
      raise Crossbeams::InfoError, "Validation error: #{res.messages}"
    end
  end
end
