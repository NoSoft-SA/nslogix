# frozen_string_literal: true

module MasterfilesApp
  class ActualCount < Dry::Struct
    attribute :id, Types::Integer
    attribute :standard_count_id, Types::Integer
    attribute :basic_pack_id, Types::Integer
    attribute :actual_count_value, Types::Integer
    attribute :standard_pack_ids, Types::Array
    attribute :size_reference_ids, Types::Array
    attribute :standard_count, Types::String
    attribute :basic_pack_code, Types::String
    attribute? :active, Types::Bool
    attribute :size_references, Types::Array.default([].freeze) do
      attribute :id, Types::Integer
      attribute :size_reference, Types::String
    end
    attribute :standard_packs, Types::Array.default([].freeze) do
      attribute :id, Types::Integer
      attribute :standard_pack_code, Types::String
    end
  end
end