# frozen_string_literal: true

module MasterfilesApp
  class SizeReferenceInteractor < BaseInteractor
    def create_size_reference(params) # rubocop:disable Metrics/AbcSize
      res = validate_size_reference_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_size_reference(res)
        log_status(:size_references, id, 'CREATED')
        log_transaction
      end
      instance = size_reference(id)
      success_response("Created size reference #{instance.size_reference}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_reference: ['This size reference already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_size_reference(id, params)
      res = validate_size_reference_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_size_reference(id, res)
        log_transaction
      end
      instance = size_reference(id)
      success_response("Updated size reference #{instance.size_reference}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_size_reference(id)
      name = size_reference(id).size_reference
      repo.transaction do
        repo.delete_size_reference(id)
        log_status(:size_references, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted size reference #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::SizeReference.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def size_reference(id)
      repo.find_size_reference(id)
    end

    def validate_size_reference_params(params)
      SizeReferenceSchema.call(params)
    end
  end
end
