# frozen_string_literal: true

module LogisticsApp
  class CreatePalletSequence < BaseService
    attr_accessor :params
    attr_reader :repo, :status, :user

    def initialize(params, status, user)
      @repo = LogisticsApp::PalletRepo.new
      @params = params
      @status = status
      @user = user
    end

    def call
      res = check_permission(:create, params)
      return res unless res.success

      create_pallet_sequence
    end

    private

    def create_pallet_sequence # rubocop:disable Metrics/AbcSize
      res = LogisticsApp::PalletSchema.call(params)
      return validation_failed_response(res) if res.failure?

      if repo.find_pallet(params).nil?
        pallet_id = repo.create_pallet(res)
        repo.log_status(:pallets, pallet_id, status)

        params.merge!(pallet_id: pallet_id)
      end

      res = LogisticsApp::PalletSequenceSchema.call(params)
      return validation_failed_response(res) if res.failure?

      sequence_id = repo.create_pallet_sequence(res)
      repo.log_status(:pallet_sequences, sequence_id, status)

      success_response(status)
    end

    def check_permission(task, params)
      TaskPermissionCheck::PalletSequence.call(task, params)
    end
  end
end
