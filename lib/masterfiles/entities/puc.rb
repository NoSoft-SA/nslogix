# frozen_string_literal: true

module MasterfilesApp
  class Puc < Dry::Struct
    attribute :id, Types::Integer
    attribute :puc_code, Types::String
    attribute :gap_code, Types::String
    attribute? :active, Types::Bool
  end
end
