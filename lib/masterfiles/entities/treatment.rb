# frozen_string_literal: true

module MasterfilesApp
  class Treatment < Dry::Struct
    attribute :id, Types::Integer
    attribute :treatment_type_id, Types::Integer
    attribute :treatment_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
    attribute :treatment_type_code, Types::String
  end
end
