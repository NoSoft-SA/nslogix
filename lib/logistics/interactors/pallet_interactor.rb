# frozen_string_literal: true

module LogisticsApp
  class PalletInteractor < BaseInteractor
    def create_pallet(params) # rubocop:disable Metrics/AbcSize
      res = validate_pallet_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_pallet(res)
        log_status(:pallets, id, 'CREATED')
        log_transaction
      end
      instance = pallet(id)
      success_response("Created pallet #{instance.pallet_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { pallet_number: ['This pallet already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_pallet(id, params)
      res = validate_pallet_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_pallet(id, res)
        log_transaction
      end
      instance = pallet(id)
      success_response("Updated pallet #{instance.pallet_number}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_pallet(id) # rubocop:disable Metrics/AbcSize
      name = pallet(id).pallet_number
      repo.transaction do
        repo.delete_pallet(id)
        log_status(:pallets, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted pallet #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Sequel::ForeignKeyConstraintViolation => e
      failed_response("Unable to delete pallet. It is still referenced#{e.message.partition('referenced').last}")
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::Pallet.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= PalletRepo.new
    end

    def pallet(id)
      repo.find_pallet(id)
    end

    def validate_pallet_params(params)
      PalletSchema.call(params)
    end
  end
end
