# frozen_string_literal: true

module LogisticsApp
  class PalletSequence < Dry::Struct
    attribute :id, Types::Integer
    attribute :pallet_id, Types::Integer
    attribute :pallet_number, Types::String
    attribute :pallet_sequence_number, Types::Integer
    attribute :farm_id, Types::Integer
    attribute :puc_id, Types::Integer
    attribute :orchard_id, Types::Integer
    attribute :cultivar_group_id, Types::Integer
    attribute :cultivar_id, Types::Integer
    attribute :season_id, Types::Integer
    attribute :grade_id, Types::Integer
    attribute :marketing_variety_id, Types::Integer
    attribute :customer_variety_id, Types::Integer
    attribute :standard_pack_id, Types::Integer
    attribute :marketing_org_party_role_id, Types::Integer
    attribute :packed_tm_group_id, Types::Integer
    attribute :mark_id, Types::Integer
    attribute :inventory_code_id, Types::Integer
    attribute :extended_columns, Types::Hash
    attribute :client_size_reference, Types::String
    attribute :client_product_code, Types::String
    attribute :treatment_ids, Types::Array
    attribute :marketing_order_number, Types::String
    attribute :carton_quantity, Types::Integer
    attribute :exit_ref, Types::String
    attribute :scrapped_at, Types::DateTime
    attribute :nett_weight, Types::Decimal
    attribute :production_run, Types::String
    attribute :production_line, Types::String
    attribute :packhouse, Types::String
    attribute :pick_ref, Types::String
    attribute :sell_by_code, Types::String
    attribute :product_chars, Types::String
    attribute :repacked_at, Types::DateTime
    attribute :failed_otmc_results, Types::Array
    attribute :phyto_data, Types::String
    attribute? :active, Types::Bool
  end
end
