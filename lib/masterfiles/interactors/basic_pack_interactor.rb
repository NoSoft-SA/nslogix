# frozen_string_literal: true

module MasterfilesApp
  class BasicPackInteractor < BaseInteractor
    def create_basic_pack(params)
      res = validate_basic_pack_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_basic_pack(res)
      instance = basic_pack(id)
      success_response("Created basic pack #{instance.basic_pack_code}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { basic_pack_code: ['This basic pack already exists'] }))
    end

    def update_basic_pack(id, params)
      @id = id
      res = validate_basic_pack_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_basic_pack(id, res)
      instance = basic_pack(id)
      success_response("Updated basic pack #{instance.basic_pack_code}",
                       instance)
    end

    def delete_basic_pack(id)
      name = basic_pack(id).basic_pack_code
      res = {}
      repo.transaction do
        res = repo.delete_basic_pack(id)
      end
      if res[:error]
        failed_response(res[:error])
      else
        success_response("Deleted basic pack #{name}")
      end
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::BasicPack.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def basic_pack(id)
      repo.find_basic_pack(id)
    end

    def validate_basic_pack_params(params)
      BasicPackSchema.call(params)
    end
  end
end
