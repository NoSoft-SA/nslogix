# frozen_string_literal: true

module MasterfilesApp
  class StandardPackInteractor < BaseInteractor
    def create_standard_pack(params)
      res = validate_standard_pack_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_standard_pack(res)
      end
      instance = standard_pack(id)
      success_response("Created standard pack #{instance.standard_pack_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { standard_pack_code: ['This standard pack already exists'] }))
    end

    def update_standard_pack(id, params)
      res = validate_standard_pack_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_standard_pack(id, res)
      end
      instance = standard_pack(id)
      success_response("Updated standard pack #{instance.standard_pack_code}", instance)
    end

    def delete_standard_pack(id)
      name = standard_pack(id).standard_pack_code
      res = nil
      repo.transaction do
        res = repo.delete_standard_pack(id)
      end
      if res.success
        success_response("Deleted standard pack #{name}")
      else
        failed_response(res.message)
      end
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def standard_pack(id)
      repo.find_standard_pack_flat(id)
    end

    def validate_standard_pack_params(params)
      StandardPackSchema.call(params)
    end
  end
end
