# frozen_string_literal: true

module MasterfilesApp
  class FarmGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :owner_party_role_id, Types::Integer
    attribute :farm_group_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
