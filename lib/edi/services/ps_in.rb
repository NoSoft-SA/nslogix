# frozen_string_literal: true

module EdiApp
  class PsIn < BaseEdiInService
    attr_accessor :missing_masterfiles
    attr_reader :user

    def initialize(edi_in_transaction_id, file_path, logger, edi_result)
      @user = OpenStruct.new(user_name: 'System')
      @missing_masterfiles = []
      super(edi_in_transaction_id, file_path, logger, edi_result)
    end

    def call
      header = edi_records.select { |rec| rec[:header].to_s == 'BH' }.to_s
      match_data_on(header)

      process_records

      # check_missing_masterfiles

      success_response('PS processed')
    end

    private

    def process_records
      res = nil
      pallets = edi_records.select { |rec| rec[:record_type].to_s == 'PS' }.group_by { |rec| rec[:sscc] }
      pallets.each do |pallet|
        res = LogisticsApp::ProcessPallet.call(flow_type: 'PS',
                                               pallet_number: pallet[0],
                                               pallet_sequences: pallet[1],
                                               user: user)
        log pallet[0]
        log res
      end
    end
  end
end
