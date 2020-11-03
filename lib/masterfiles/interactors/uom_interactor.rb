# frozen_string_literal: true

module MasterfilesApp
  class UomInteractor < BaseInteractor
    def create_uom(params) # rubocop:disable Metrics/AbcSize
      res = validate_uom_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_uom(res)
        log_status(:uoms, id, 'CREATED')
        log_transaction
      end
      instance = uom(id)
      success_response("Created uom #{instance.uom_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { uom_code: ['This uom already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_uom(id, params)
      res = validate_uom_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_uom(id, res)
        log_transaction
      end
      instance = uom(id)
      success_response("Updated uom #{instance.uom_code}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_uom(id) # rubocop:disable Metrics/AbcSize
      name = uom(id).uom_code
      repo.transaction do
        repo.delete_uom(id)
        log_status(:uoms, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted uom #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Sequel::ForeignKeyConstraintViolation => e
      failed_response("Unable to delete uom. It is still referenced#{e.message.partition('referenced').last}")
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::Uom.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= UomRepo.new
    end

    def uom(id)
      repo.find_uom(id)
    end

    def validate_uom_params(params)
      UomSchema.call(params)
    end
  end
end
