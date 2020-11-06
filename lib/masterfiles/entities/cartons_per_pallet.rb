# frozen_string_literal: true

module MasterfilesApp
  class CartonsPerPallet < Dry::Struct
    attribute :id, Types::Integer
    attribute :description, Types::String
    attribute :pallet_format_id, Types::Integer
    attribute :basic_pack_id, Types::Integer
    attribute :cartons_per_pallet, Types::Integer
    attribute :layers_per_pallet, Types::Integer
    attribute :basic_pack_code, Types::Integer
    attribute :pallet_formats_description, Types::Integer
    attribute? :active, Types::Bool
  end
end
