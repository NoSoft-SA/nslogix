# frozen_string_literal: true

module LogisticsApp
  class Pallet < Dry::Struct
    attribute :id, Types::Integer
    attribute :edi_in_transaction_id, Types::Integer
    attribute :pallet_number, Types::String
    attribute :exit_ref, Types::String
    attribute :scrapped_at, Types::DateTime
    attribute :shipped_at, Types::DateTime
    attribute :shipped, Types::Bool
    attribute :stock_created_at, Types::DateTime
    attribute :in_stock, Types::Bool
    attribute :inspected, Types::Bool
    attribute :govt_first_inspection_at, Types::DateTime
    attribute :govt_reinspection_at, Types::DateTime
    attribute :govt_inspection_passed, Types::Bool
    attribute :internal_inspection_passed, Types::Bool
    attribute :internal_inspection_at, Types::DateTime
    attribute :internal_reinspection_at, Types::DateTime
    attribute :phc, Types::String
    attribute :intake_created_at, Types::DateTime
    attribute :first_cold_storage_at, Types::DateTime
    attribute :cooled, Types::Bool
    attribute :gross_weight, Types::Decimal
    attribute :nett_weight, Types::Decimal
    attribute :weight_measured_at, Types::DateTime
    attribute :on_site_location, Types::String
    attribute :consignment_note_number, Types::String
    attribute :original_consignment_note_number, Types::String
    attribute :inspection_point, Types::String
    attribute :original_inspection_point, Types::String
    attribute :carton_quantity, Types::Integer
    attribute :allocated, Types::Bool
    attribute :allocated_at, Types::DateTime
    attribute :reinspected, Types::Bool
    attribute :scrapped, Types::Bool
    attribute :repacked, Types::Bool
    attribute :repacked_at, Types::DateTime
    attribute :temp_tail, Types::String
    attribute? :active, Types::Bool
  end
end
