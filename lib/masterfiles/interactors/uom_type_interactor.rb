# frozen_string_literal: true

module MasterfilesApp
  class UomTypeInteractor < BaseInteractor
    def create_uom_type(params)
      res = validate_uom_type_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_uom_type(res)
        log_status(:uom_types, id, 'CREATED')
        log_transaction
      end
      instance = uom_type(id)
      success_response("Created uom type #{instance.uom_type_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { uom_type_code: ['This uom type already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_uom_type(id, params)
      res = validate_uom_type_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_uom_type(id, res)
        log_transaction
      end
      instance = uom_type(id)
      success_response("Updated uom type #{instance.uom_type_code}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_uom_type(id)
      name = uom_type(id).uom_type_code
      repo.transaction do
        repo.delete_uom_type(id)
        log_status(:uom_types, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted uom type #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Sequel::ForeignKeyConstraintViolation => e
      failed_response("Unable to delete uom type. It is still referenced#{e.message.partition('referenced').last}")
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::UomType.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= UomRepo.new
    end

    def uom_type(id)
      repo.find_uom_type(id)
    end

    def validate_uom_type_params(params)
      UomTypeSchema.call(params)
    end
  end
end