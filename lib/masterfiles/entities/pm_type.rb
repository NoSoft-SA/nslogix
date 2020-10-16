# frozen_string_literal: true

module MasterfilesApp
  class PmType < Dry::Struct
    attribute :id, Types::Integer
    attribute :pm_type_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
