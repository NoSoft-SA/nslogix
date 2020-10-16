# frozen_string_literal: true

module MasterfilesApp
  class RmtDeliveryDestination < Dry::Struct
    attribute :id, Types::Integer
    attribute :delivery_destination_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
