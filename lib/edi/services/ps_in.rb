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

      process_pallets

      check_missing_masterfiles

      failed_response('stub')
      # success_response('PS processed')
    end

    private

    def process_pallets # rubocop:disable Metrics/AbcSize
      pallets = edi_records.select { |rec| rec[:record_type].to_s == 'PS' }.group_by { |rec| rec[:sscc] }

      pallets.each do |pallet_number, sequences|
        repo.transaction do
          res = PalletSchema.call(build_pallet(pallet_number, sequences.first))
          return validation_failed_response(res) if res.failure?

          repo.create_with_status(:pallets, 'CREATED FROM PS', res)

          sequences.each do |sequence|
            res = PalletSequenceSchema.call(build_sequence(pallet_number, sequence))
            return validation_failed_response(res) if res.failure?

            repo.create_with_status(:pallet_sequences, 'CREATED FROM PS', res)
          end

          log_transaction
        end
      end
      success_response('Created pallet')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def build_pallet(pallet_number, sequence) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      originally_inspected_at = repo.time_from_date_val(sequence[:orig_inspec_date])
      inspected_at = repo.time_from_date_val(sequence[:inspec_date])
      intake_created_at = repo.time_from_date_val(sequence[:intake_date])
      weight_measured_at = repo.time_from_date_and_time(sequence[:weighing_date], sequence[:weighing_time])

      pallet = {}
      pallet[:govt_first_inspection_at] = originally_inspected_at
      pallet[:govt_reinspection_at] = inspected_at if originally_inspected_at != inspected_at
      pallet[:standard_pack_code_id] = repo.get_masterfile_or_variant(:standard_pack_codes, standard_pack_code: sequence[:pack])

      get_masterfile_or_variant(:basic_pack_codes, basic_pack_code: sequence[:pack])

      pallet[:basic_pack_code_id] = repo.get_masterfile_value(table_name, column, args)

      pallet[:fruit_size_reference_id] = repo.get_masterfile_or_variant(:fruit_size_references, fruit_size_reference: sequence[:size_count])

      basic_pack_code_id = repo.find_basic_pack_code_id(standard_pack_code_id)
      rec[:lookup_data][:basic_pack_code_id] = basic_pack_code_id
      rec[:missing_mf][:basic_pack_code_id] = { mode: :direct, raise: false, keys: { size_count: sequence[:size_count] } } if basic_pack_code_id.nil?

      pallet_format_id, cartons_per_pallet_id = repo.find_pallet_format_and_cpp_id(sequence[:pallet_btype], tot_cartons, basic_pack_code_id)
      rec[:lookup_data][:pallet_format_id] = pallet_format_id
      rec[:missing_mf][:pallet_format_id] = { mode: :direct, raise: true, keys: { pallet_btype: sequence[:pallet_btype], cartons: tot_cartons, basic_pack_code_id: basic_pack_code_id } } if pallet_format_id.nil?
      rec[:lookup_data][:cartons_per_pallet_id] = cartons_per_pallet_id
      rec[:missing_mf][:cartons_per_pallet_id] = { mode: :direct, raise: true, keys: { pallet_btype: sequence[:pallet_btype], cartons: tot_cartons, basic_pack_code_id: basic_pack_code_id } } if cartons_per_pallet_id.nil?

      # pallet_format_id: 0, # lookup
      {
        depot_pallet: true,
        edi_in_consignment_note_number: sequence[:cons_no],
        edi_in_transaction_id: edi_in_transaction.id,
        pallet_number: pallet_number,
        in_stock: true,
        inspected: !orig_inspec_date.nil? || !inspec_date.nil?,

        stock_created_at: intake_date || inspec_date || Time.now,
        phc: sequence[:packh_code],
        intake_created_at: intake_date,
        gross_weight: sequence[:pallet_gross_mass].nil? || sequence[:pallet_gross_mass].to_f.zero? ? nil : sequence[:pallet_gross_mass],
        gross_weight_measured_at: weighed_date,
        palletized: true,
        palletized_at: intake_date,
        created_at: intake_date,
        reinspected: !reinspect_at.nil?,
        govt_inspection_passed: !orig_inspec_date.nil? || !inspec_date.nil?,
        cooled: false,
        temp_tail: sequence[:temp_device_id],
        edi_in_inspection_point: sequence[:inspect_pnt]
      }
    end

    def build_sequence(pallet_number, sequence) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      rec = {
        lookup_data: {},  # data looked up from masterfiles.
        missing_mf: {},   # details about failed lookups
        missing_data: {}, # non-lookup data that should be in the file but is not.
        record: {}        # data that maps directly from the file
      }

      parent = records[pallet_number]

      inspec_date = repo.time_from_date_val(sequence[:inspec_date])
      tran_date = repo.time_from_date_val(sequence[:tran_date])

      puc_id = repo.find_puc_id(sequence[:farm])
      rec[:lookup_data][:puc_id] = puc_id
      rec[:missing_mf][:puc_id] = { mode: :direct, raise: true, keys: { farm: sequence[:farm] } } if puc_id.nil?

      farm_id = repo.find_farm_id(puc_id)
      rec[:lookup_data][:farm_id] = farm_id
      rec[:missing_mf][:farm_id] = { mode: :indirect, raise: true, keys: { puc_id: puc_id } } if farm_id.nil?
      orchard_id = repo.find_orchard_id(farm_id, sequence[:orchard])
      rec[:lookup_data][:orchard_id] = orchard_id
      rec[:missing_mf][:orchard_id] = { mode: :direct, raise: false, keys: { farm_id: farm_id, orchard: sequence[:orchard] } } if orchard_id.nil?
      marketing_variety_id = repo.find_marketing_variety_id(sequence[:variety])
      rec[:lookup_data][:marketing_variety_id] = marketing_variety_id
      rec[:missing_mf][:marketing_variety_id] = { mode: :direct, raise: true, keys: { variety: sequence[:variety] } } if marketing_variety_id.nil?
      cultivar_id = repo.find_cultivar_id_from_mkv(marketing_variety_id)
      rec[:lookup_data][:cultivar_id] = cultivar_id
      rec[:missing_mf][:cultivar_id] = { mode: :indirect, keys: { marketing_variety_id: marketing_variety_id } } if cultivar_id.nil?
      cultivar_group_id = repo.find_cultivar_group_id(cultivar_id)
      rec[:lookup_data][:cultivar_group_id] = cultivar_group_id
      rec[:missing_mf][:cultivar_group_id] = { mode: :indirect, keys: { cultivar_id: cultivar_id } } if cultivar_group_id.nil?
      season_id = repo.find_season_id(inspec_date || tran_date, cultivar_id)
      rec[:lookup_data][:season_id] = season_id
      rec[:missing_mf][:season_id] = { mode: :direct, raise: true, keys: { date: inspec_date || tran_date, cultivar_id: cultivar_id } } if season_id.nil?
      marketing_org_party_role_id = MasterfilesApp::PartyRepo.new.find_party_role_from_org_code_for_role(sequence[:orgzn], AppConst::ROLE_MARKETER)
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

      rec[:lookup_data][:basic_pack_code_id] = parent[:lookup_data][:basic_pack_code_id]
      rec[:lookup_data][:standard_pack_code_id] = parent[:lookup_data][:standard_pack_code_id]
      rec[:lookup_data][:pallet_format_id] = parent[:lookup_data][:pallet_format_id]
      rec[:lookup_data][:cartons_per_pallet_id] = parent[:lookup_data][:cartons_per_pallet_id]

      rec[:record] = {
        depot_pallet: true,
        pallet_number: pallet_number,
        carton_quantity: sequence[:ctn_qty].to_i,
        pick_ref: sequence[:pick_ref],
        sell_by_code: sequence[:sellbycode],
        product_chars: sequence[:prod_char]   # ???
      }
      records[pallet_number][:sub_records] << rec
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
