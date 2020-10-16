# frozen_string_literal: true

module MasterfilesApp
  class PalletStackType < Dry::Struct
    attribute :id, Types::Integer
    attribute :stack_type_code, Types::String
    attribute :description, Types::String
    attribute :stack_height, Types::Integer
    attribute? :active, Types::Bool
  end
end
