# frozen_string_literal: true

module LogisticsApp
  PalletSequenceSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    optional(:id).filled(:integer)
    required(:carton_quantity).filled(:integer)
    optional(:client_product_code).maybe(Types::StrippedString)
    optional(:client_size_reference).maybe(Types::StrippedString)
    required(:cultivar_group_id).filled(:integer)
    optional(:cultivar_id).maybe(:integer)
    optional(:customer_variety_id).maybe(:integer)
    optional(:exit_ref).maybe(Types::StrippedString)
    optional(:extended_columns).maybe(:hash)
    optional(:failed_otmc_results).maybe(:array).maybe { each(:integer) }
    required(:farm_id).filled(:integer)
    required(:grade_id).filled(:integer)
    required(:inventory_code_id).filled(:integer)
    required(:mark_id).filled(:integer)
    optional(:marketing_order_number).maybe(Types::StrippedString)
    required(:marketing_org_party_role_id).filled(:integer)
    required(:marketing_variety_id).filled(:integer)
    optional(:nett_weight).maybe(:decimal)
    required(:orchard_id).filled(:integer)
    required(:packed_tm_group_id).filled(:integer)
    optional(:packhouse).maybe(Types::StrippedString)
    optional(:pallet_id).maybe(:integer)
    required(:pallet_number).filled(Types::StrippedString)
    required(:pallet_sequence_number).filled(:integer)
    optional(:phyto_data).maybe(Types::StrippedString)
    optional(:pick_ref).maybe(Types::StrippedString)
    optional(:product_chars).maybe(Types::StrippedString)
    optional(:production_line).maybe(Types::StrippedString)
    optional(:production_run).maybe(Types::StrippedString)
    required(:puc_id).filled(:integer)
    optional(:repacked_at).maybe(:time)
    optional(:scrapped_at).maybe(:time)
    required(:season_id).filled(:integer)
    optional(:sell_by_code).maybe(Types::StrippedString)
    required(:standard_pack_id).filled(:integer)
    optional(:treatment_ids).maybe(:array).maybe { each(:integer) }
  end
end
