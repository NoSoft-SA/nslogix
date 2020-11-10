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
      pallet[:depot_pallet] = true
      pallet[:edi_in_consignment_note_number] = sequence[:cons_no]
      pallet[:edi_in_transaction_id] = edi_in_transaction.id
      pallet[:pallet_number] = pallet_number
      pallet[:in_stock] = true
      pallet[:inspected] = !originally_inspected_at.nil? || !inspected_at.nil?
      pallet[:weight_measured_at] = weight_measured_at
      pallet[:stock_created_at] = intake_created_at || inspected_at || Time.now
      pallet[:phc] = sequence[:packh_code]
      pallet[:intake_created_at] = intake_created_at
      pallet[:gross_weight] = sequence[:pallet_gross_mass].nil? || sequence[:pallet_gross_mass].to_f.zero? ? nil : sequence[:pallet_gross_mass]
      pallet[:gross_weight_measured_at] = weighed_date
      pallet[:palletized] = true
      pallet[:palletized_at] = intake_created_at
      pallet[:created_at] = intake_created_at
      pallet[:reinspected] = !reinspect_at.nil?
      pallet[:govt_inspection_passed] = !originally_inspected_at.nil? || !inspected_at.nil?
      pallet[:cooled] = false
      pallet[:temp_tail] = sequence[:temp_device_id]
      pallet[:edi_in_inspection_point] = sequence[:inspect_pnt]
      pallet[:carton_quantity] = sequence[:ctn_qty].to_i
      pallet[:pick_ref] = sequence[:pick_ref]
      pallet[:sell_by_code] = sequence[:sellbycode]
      pallet[:product_chars] = sequence[:prod_char]
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
      pallet[:marketing_org_party_role_id] = MasterfilesApp::PartyRepo.new.find_party_role_from_org_code(sequence[:orgzn], AppConst::ROLE_MARKETER)
      pallet[:packed_tm_group_id] = repo.get_variant_id(:target_market_groups, target_market_group_name: sequence[:targ_mkt])
      pallet[:mark_id] = repo.get_variant_id(:marks, mark_code: sequence[:mark])
      pallet[:grade_id] = repo.get_variant_id(:grades, grade_code: sequence[:grade])
      pallet[:inventory_code_id] = repo.get_variant_id(:inventory_codes, inventory_code: sequence[:inv_code])
      pallet
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
