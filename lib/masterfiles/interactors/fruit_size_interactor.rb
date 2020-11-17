# frozen_string_literal: true

module MasterfilesApp
  class FruitSizeInteractor < BaseInteractor
    def create_standard_count(params)
      res = validate_standard_count_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_standard_count(res)
      instance = standard_count(id)
      success_response("Created standard count #{instance.size_count_description}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { size_count_description: ['This standard count already exists'] }))
    end

    def update_standard_count(id, params)
      res = validate_standard_count_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_standard_count(id, res)
      instance = standard_count(id)
      success_response("Updated standard count #{instance.size_count_description}", instance)
    end

    def delete_standard_count(id)
      name = standard_count(id).size_count_description
      repo.delete_standard_count(id)
      success_response("Deleted standard count #{name}")
    end

    def create_actual_count(parent_id, params)
      params[:standard_count_id] = parent_id
      res = validate_actual_count_params(params)
      return validation_failed_response(res) if res.failure?

      id = repo.create_actual_count(res)
      instance = actual_count(id)
      success_response("Created fruit actual counts for pack #{instance.id}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { actual_count_value: ['This fruit actual counts for pack already exists'] }))
    end

    def update_actual_count(id, params)
      res = validate_actual_count_params(params)
      return validation_failed_response(res) if res.failure?

      repo.update_actual_count(id, res)
      instance = actual_count(id)
      success_response("Updated fruit actual counts for pack #{instance.id}", instance)
    end

    def delete_actual_count(id)
      name = actual_count(id).id
      repo.delete_actual_count(id)
      success_response("Deleted fruit actual counts for pack #{name}")
    end

    private

    def repo
      @repo ||= FruitSizeRepo.new
    end

    def standard_count(id)
      repo.find_standard_count(id)
    end

    def validate_standard_count_params(params)
      StandardCountSchema.call(params)
    end

    def actual_count(id)
      repo.find_actual_count(id)
    end

    def validate_actual_count_params(params)
      ActualCountSchema.call(params)
    end
  end
end
