# frozen_string_literal: true

module MasterfilesApp
  class TreatmentType < Dry::Struct
    attribute :id, Types::Integer
    attribute :treatment_type_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
