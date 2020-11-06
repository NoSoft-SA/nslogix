# frozen_string_literal: true

module MasterfilesApp
  class StandardPack < Dry::Struct
    attribute :id, Types::Integer
    attribute :standard_pack_code, Types::String
    attribute :material_mass, Types::Decimal
    attribute :description, Types::String
    attribute :standard_pack_label, Types::String
    attribute :basic_pack_id, Types::Integer
    attribute :use_size_ref_for_edi, Types::Bool
    attribute? :active, Types::Bool
  end

  class StandardPackFlat < Dry::Struct
    attribute :id, Types::Integer
    attribute :standard_pack_code, Types::String
    attribute :material_mass, Types::Decimal
    attribute :description, Types::String
    attribute :standard_pack_label, Types::String
    attribute :basic_pack_id, Types::Integer
    attribute :basic_pack_code, Types::String
    attribute :use_size_ref_for_edi, Types::Bool
    attribute? :active, Types::Bool
  end
end
