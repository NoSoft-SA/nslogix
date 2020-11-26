# frozen_string_literal: true

module LogisticsApp
  class UpdatePalletSequence < BaseService
    attr_accessor :params
    attr_reader :repo, :status, :user

    def initialize(params, status, user)
      @repo = LogisticsApp::PalletRepo.new
      @params = params
      @status = status
      @user = user
    end

    def call
      res = check_permission(:update, params)
      return res unless res.success

      update_pallet_sequence
    end

    private

    def update_pallet_sequence # rubocop:disable Metrics/AbcSize
      res = LogisticsApp::PalletSchema.call(params)
      return validation_failed_response(res) if res.failure?

      pallet = repo.find_pallet(params)
      repo.update_pallet(pallet.id, res)
      repo.log_status(:pallets, pallet.id, status)

      res = LogisticsApp::PalletSequenceSchema.call(params)
      return validation_failed_response(res) if res.failure?

      sequence = repo.find_pallet_sequence(params)
      repo.update_pallet_sequence(sequence.id, res)
      repo.log_status(:pallet_sequences, sequence.id, status)

      success_response(status)
    end

    def check_permission(task, params)
      TaskPermissionCheck::PalletSequence.call(task, params)
    end
  end
end
