# frozen_string_literal: true

module MasterfilesApp
  class UomType < Dry::Struct
    attribute :id, Types::Integer
    attribute :code, Types::String
    attribute? :active, Types::Bool
  end
end
