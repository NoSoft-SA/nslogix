# frozen_string_literal: true

module LogisticsApp
  class PalletSequenceInteractor < BaseInteractor
    def create_pallet_sequence(params) # rubocop:disable Metrics/AbcSize
      res = validate_pallet_sequence_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_pallet_sequence(res)
        log_status(:pallet_sequences, id, 'CREATED')
        log_transaction
      end
      instance = pallet_sequence(id)
      success_response("Created pallet sequence #{instance.pallet_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { pallet_number: ['This pallet sequence already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_pallet_sequence(id, params)
      res = validate_pallet_sequence_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_pallet_sequence(id, res)
        log_transaction
      end
      instance = pallet_sequence(id)
      success_response("Updated pallet sequence #{instance.pallet_number}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_pallet_sequence(id) # rubocop:disable Metrics/AbcSize
      name = pallet_sequence(id).pallet_number
      repo.transaction do
        repo.delete_pallet_sequence(id)
        log_status(:pallet_sequences, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted pallet sequence #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Sequel::ForeignKeyConstraintViolation => e
      puts e.message
      failed_response("Unable to delete pallet sequence. It is still referenced#{e.message.partition('referenced').last}")
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::PalletSequence.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= PalletRepo.new
    end

    def pallet_sequence(id)
      repo.find_pallet_sequence(id)
    end

    def validate_pallet_sequence_params(params)
      PalletSequenceSchema.call(params)
    end
  end
end
