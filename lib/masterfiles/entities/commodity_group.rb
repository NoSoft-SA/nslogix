# frozen_string_literal: true

module MasterfilesApp
  class CommodityGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :commodity_group_code, Types::String
    attribute :description, Types::String
    attribute :active, Types::Bool
  end
end
