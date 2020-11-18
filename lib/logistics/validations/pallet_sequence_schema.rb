# frozen_string_literal: true

module LogisticsApp
  PalletSequenceSchema = Dry::Schema.Params do # rubocop:disable Metrics/BlockLength
    optional(:id).filled(:integer)
    required(:pallet_id).maybe(:integer)
    required(:pallet_number).filled(Types::StrippedString)
    required(:pallet_sequence_number).filled(:integer)
    required(:farm_id).filled(:integer)
    required(:puc_id).filled(:integer)
    required(:orchard_id).filled(:integer)
    required(:cultivar_group_id).filled(:integer)
    required(:cultivar_id).maybe(:integer)
    required(:season_id).filled(:integer)
    required(:grade_id).filled(:integer)
    required(:marketing_variety_id).filled(:integer)
    required(:customer_variety_id).maybe(:integer)
    required(:standard_pack_id).filled(:integer)
    required(:marketing_org_party_role_id).filled(:integer)
    required(:packed_tm_group_id).filled(:integer)
    required(:mark_id).filled(:integer)
    required(:inventory_code_id).filled(:integer)
    required(:extended_columns).maybe(:hash)
    required(:client_size_reference).maybe(Types::StrippedString)
    required(:client_product_code).maybe(Types::StrippedString)
    required(:treatment_ids).maybe(:array).maybe { each(:integer) }
    required(:marketing_order_number).maybe(Types::StrippedString)
    required(:carton_quantity).filled(:integer)
    required(:exit_ref).maybe(Types::StrippedString)
    required(:scrapped_at).maybe(:time)
    required(:nett_weight).maybe(:decimal)
    required(:production_run).maybe(Types::StrippedString)
    required(:production_line).maybe(Types::StrippedString)
    required(:packhouse).maybe(Types::StrippedString)
    required(:pick_ref).maybe(Types::StrippedString)
    required(:sell_by_code).maybe(Types::StrippedString)
    required(:product_chars).maybe(Types::StrippedString)
    required(:repacked_at).maybe(:time)
    required(:failed_otmc_results).maybe(:array).maybe { each(:integer) }
    required(:phyto_data).maybe(Types::StrippedString)
  end
end
