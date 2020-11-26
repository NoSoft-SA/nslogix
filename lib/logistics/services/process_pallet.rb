# frozen_string_literal: true

module LogisticsApp
  class ProcessPallet < BaseService
    attr_reader :repo, :user, :flow_type, :pallet_number, :pallet_sequences
    attr_accessor :res

    def initialize(flow_type:, pallet_number:, pallet_sequences:, user:)
      @repo = PalletRepo.new
      @user = user
      @flow_type = flow_type
      @pallet_number = pallet_number
      @pallet_sequences = [pallet_sequences].flatten
      @res = failed_response('Failed to process pallet')
    end

    def call # rubocop:disable Metrics/AbcSize
      repo.transaction do
        repo.delete_pallet_quarantine(pallet_number)
        pallet_sequences.each do |sequence|
          @res = case flow_type
                 when 'PS'
                   EdiApp::PsInRepo.new.ps_in_row(sequence)
                 else
                   failed_response("Flow Type #{flow_type}, not matched")
                   raise Crossbeams::InfoError
                 end

          failed_process(flow_type, pallet_number, sequence, res) unless res.success

          attrs = res.to_h
          @res = if repo.find_pallet_sequence(attrs).nil?
                   CreatePalletSequence.call(attrs, 'CREATED FROM PS', @user)
                 else
                   UpdatePalletSequence.call(attrs, 'UPDATED FROM PS', @user)
                 end
          failed_process(flow_type, pallet_number, sequence, res) unless res.success
        end
        success_response('Pallet processed')
      end
    rescue Crossbeams::InfoError
      res
    end

    private

    def failed_process(flow_type, pallet_number, sequence, error_response)
      repo.create_pallet_quarantine(flow_type, pallet_number, sequence, error_response)
      raise Crossbeams::InfoError
    end
  end
end
