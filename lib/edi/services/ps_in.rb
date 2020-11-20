# frozen_string_literal: true

module EdiApp
  class PsIn < BaseEdiInService # rubocop:disable Metrics/ClassLength
    attr_accessor :missing_masterfiles, :pallet_number
    attr_reader :user, :repo, :pallet_repo

    def initialize(edi_in_transaction_id, file_path, logger, edi_result)
      @repo = PsInRepo.new
      @pallet_repo = LogisticsApp::PalletRepo.new
      @user = OpenStruct.new(user_name: 'System')
      @missing_masterfiles = []
      @pallet_number = nil
      super(edi_in_transaction_id, file_path, logger, edi_result)
    end

    def call
      header = edi_records.select { |rec| rec[:header].to_s == 'BH' }.to_s
      match_data_on(header)

      process_records

      check_missing_masterfiles

      failed_response('stub')
    # success_response('PS processed')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    private

    def process_records # rubocop:disable Metrics/AbcSize
      pallets = edi_records.select { |rec| rec[:record_type].to_s == 'PS' }.group_by { |rec| rec[:sscc] }
      pallets.each do |pallet|
        @pallet_number = pallet[0]

        repo.transaction do
          pallet[1].each do |sequence|
            attrs = build_attrs(sequence)
            pallet_sequence = pallet_repo.find_pallet_sequence(attrs)

            if pallet_sequence.nil?
              create_pallet_sequence(attrs)
            else
              update_pallet_sequence(attrs)
            end
          end
          log_transaction
        end

      end
      success_response('Processed pallets')
    end

    def create_pallet_sequence(params) # rubocop:disable Metrics/AbcSize
      check_permission!(:create, params)
      res = LogisticsApp::PalletSchema.call(params)
      return validation_failed_response(res) if res.failure?

      if pallet_repo.find_pallet(params).nil?
        pallet_id = pallet_repo.create_pallet(res)
        log_status(:pallets, pallet_id, 'CREATED FROM PS')

        params.merge!(pallet_id: pallet_id)
      end

      res = LogisticsApp::PalletSequenceSchema.call(params)
      return validation_failed_response(res) if res.failure?

      sequence_id = pallet_repo.create_pallet_sequence(res)
      log_status(:pallet_sequences, sequence_id, 'CREATED FROM PS')

      success_response('Created pallet')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_pallet_sequence(params) # rubocop:disable Metrics/AbcSize
      check_permission!(:update, params)
      res = LogisticsApp::PalletSchema.call(params)
      return validation_failed_response(res) if res.failure?

      pallet = pallet_repo.find_pallet(params)
      pallet_repo.update_pallet(pallet.id, res)
      log_status(:pallets, pallet.id, 'UPDATED FROM PS')

      res = LogisticsApp::PalletSequenceSchema.call(params)
      return validation_failed_response(res) if res.failure?

      sequence = pallet_repo.find_pallet_sequence(params)
      pallet_repo.update_pallet_sequence(sequence.id, res)
      log_status(:pallet_sequences, sequence.id, 'UPDATED FROM PS')

      success_response('Updated pallet')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def build_attrs(sequence) # rubocop:disable Metrics/AbcSize
      originally_inspected_at = repo.time_from_date_val(sequence[:orig_inspec_date])
      inspected_at = repo.time_from_date_val(sequence[:inspec_date])
      intake_created_at = repo.time_from_date_val(sequence[:intake_date])
      weight_measured_at = repo.time_from_date_and_time(sequence[:weighing_date], sequence[:weighing_time])
      transaction_at = repo.time_from_date_val(sequence[:tran_date])

      pallet_sequence = {}
      pallet_sequence[:carton_quantity] = sequence[:ctn_qty].to_i
      pallet_sequence[:cooled] = false
      pallet_sequence[:created_at] = intake_created_at
      pallet_sequence[:cultivar_group_id] = get_masterfile_id(:cultivar_groups, cultivar_group_code: sequence[:cultivar_group])
      pallet_sequence[:cultivar_id] = get_masterfile_id(:cultivars, cultivar_code: sequence[:cultivar_code])
      pallet_sequence[:depot_pallet] = true
      pallet_sequence[:edi_in_consignment_note_number] = sequence[:cons_no]
      pallet_sequence[:edi_in_inspection_point] = sequence[:inspect_pnt]
      pallet_sequence[:edi_in_transaction_id] = edi_in_transaction.id
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
      pallet_sequence[:pallet_number] = pallet_number
      pallet_sequence[:palletized] = true
      pallet_sequence[:palletized_at] = intake_created_at
      pallet_sequence[:phc] = sequence[:packh_code]
      pallet_sequence[:pick_ref] = sequence[:pick_ref]
      pallet_sequence[:product_chars] = sequence[:prod_char]
      pallet_sequence[:puc_id] = get_masterfile_id(:pucs, puc_code: sequence[:farm])
      pallet_sequence[:farm_id] = repo.get_value(:farms_pucs, :farm_id, puc_id: pallet_sequence[:puc_id])
      pallet_sequence[:orchard_id] = get_masterfile_id(:orchards, orchard_code: sequence[:orchard], puc_id: pallet_sequence[:puc_id])
      pallet_sequence[:reinspected] = inspected_at != originally_inspected_at
      pallet_sequence[:season_id] = MasterfilesApp::CalendarRepo.new.get_season_id(pallet_sequence[:cultivar_id], inspected_at || transaction_at)
      pallet_sequence[:sell_by_code] = sequence[:sellbycode]
      pallet_sequence[:size_reference_id] = get_masterfile_id(:size_references, size_reference: sequence[:size_count])
      pallet_sequence[:standard_pack_id] = get_masterfile_id(:standard_packs, standard_pack_code: sequence[:pack])
      pallet_sequence[:stock_created_at] = intake_created_at || inspected_at || Time.now
      pallet_sequence[:temp_tail] = sequence[:temp_device_id]
      pallet_sequence[:weight_measured_at] = weight_measured_at
      pallet_sequence
    end

    def check_permission!(task, params)
      res = LogisticsApp::TaskPermissionCheck::PalletSequence.call(task, params)
      raise Crossbeams::InfoError, res.message unless res.success
    end

    def get_masterfile_id(table_name, args)
      id = repo.get_variant_id(table_name, args)
      return id unless id.nil?

      missing_masterfiles << ["#{table_name}:#{args}"]
      nil
    end

    def check_missing_masterfiles
      return if missing_masterfiles.empty?

      notes = "Missing masterfiles: #{missing_masterfiles.uniq.sort.join(", \n")}"
      missing_masterfiles_detected(notes)
      raise Crossbeams::InfoError, 'Missing masterfiles'
    end

    def validation_failed_response(res)
      raise Crossbeams::InfoError, "Validation error: #{res.errors.to_h}"
    end
  end
end
