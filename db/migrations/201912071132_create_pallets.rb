require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers

    create_table(:pallets, ignore_index_errors: true) do
      primary_key :id
      foreign_key :pallet_format_id, :pallet_formats
      foreign_key :edi_in_transaction_id, :edi_in_transactions, type: :integer
      String :pallet_number, null: false
      String :exit_ref
      DateTime :scrapped_at
      DateTime :shipped_at
      TrueClass :shipped, default: false
      DateTime :stock_created_at
      TrueClass :in_stock, default: false
      TrueClass :inspected, default: false
      DateTime :govt_first_inspection_at
      DateTime :govt_reinspection_at

      TrueClass :govt_inspection_passed, default: false
      TrueClass :internal_inspection_passed, default: false
      DateTime :internal_inspection_at
      DateTime :internal_reinspection_at

      String :phc, null: false
      DateTime :intake_created_at
      DateTime :first_cold_storage_at
      TrueClass :cooled, default: true
      String :build_status
      Decimal :gross_weight
      Decimal :nett_weight
      DateTime :gross_weight_measured_at
      TrueClass :palletized, default: false
      TrueClass :partially_palletized, default: false
      DateTime :palletized_at
      DateTime :partially_palletized_at
      String :on_site_location
      String :consignment_note_number
      String :original_consignment_note_number
      String :inspection_point
      String :original_inspection_point
      Integer :carton_quantity
      TrueClass :allocated, default: false
      DateTime :allocated_at
      TrueClass :reinspected, default: false
      TrueClass :scrapped, default: false
      TrueClass :repacked, default: false
      DateTime :repacked_at
      String :temp_tail

      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pallet_number], name: :pallets_unique_code, unique: true
      index [:id, :pallet_number], name: :pallet_idx, unique: true
    end
    pgt_created_at(:pallets,
                   :created_at,
                   function_name: :pgt_pallets_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:pallets,
                   :updated_at,
                   function_name: :pgt_pallets_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pallets', true, true, '{updated_at}'::text[]);"



    create_table(:pallet_sequences, ignore_index_errors: true) do
      primary_key :id
      foreign_key :pallet_id, :pallets, type: :integer
      String :pallet_number, null: false
      Integer :pallet_sequence_number, null: false
      foreign_key :farm_id, :farms, type: :integer, null: false
      foreign_key :puc_id, :pucs, type: :integer, null: false
      foreign_key :orchard_id, :orchards, type: :integer, null: false
      foreign_key :cultivar_group_id, :cultivar_groups, type: :integer, null: false
      foreign_key :cultivar_id, :cultivars, type: :integer
      foreign_key :season_id, :seasons, type: :integer, null: false
      foreign_key :grade_id, :grades, type: :integer, null: false
      foreign_key :marketing_variety_id, :marketing_varieties, type: :integer, null: false
      foreign_key :customer_variety_id, :customer_varieties, type: :integer
      foreign_key :std_fruit_size_count_id, :std_fruit_size_counts, type: :integer
      foreign_key :basic_pack_code_id, :basic_pack_codes, type: :integer, null: false
      foreign_key :standard_pack_code_id, :standard_pack_codes, type: :integer, null: false
      foreign_key :fruit_actual_counts_for_pack_id, :fruit_actual_counts_for_packs, type: :integer
      foreign_key :fruit_size_reference_id, :fruit_size_references, type: :integer
      foreign_key :marketing_org_party_role_id, :party_roles, type: :integer, null: false
      foreign_key :packed_tm_group_id, :target_market_groups, type: :integer, null: false
      foreign_key :mark_id, :marks, type: :integer, null: false
      foreign_key :inventory_code_id, :inventory_codes, type: :integer, null: false
      foreign_key :pallet_format_id, :pallet_formats, type: :integer, null: false
      foreign_key :cartons_per_pallet_id, :cartons_per_pallet, type: :integer, null: false
      Jsonb :extended_columns
      String :client_size_reference
      String :client_product_code
      column :treatment_ids, 'int[]'
      String :marketing_order_number
      Integer :carton_quantity, null: false
      String :exit_ref
      DateTime :scrapped_at
      Decimal :nett_weight
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      String :production_run
      String :production_line
      String :packhouse
      String :pick_ref
      String :sell_by_code
      String :product_chars
      DateTime :repacked_at
      Integer :repacked_from_pallet_id
      TrueClass :removed_from_pallet, default: false
      Integer :scrapped_from_pallet_id
      Integer :removed_from_pallet_id
      DateTime :removed_from_pallet_at

      index [:pallet_number, :pallet_sequence_number], name: :pallet_sequences_idx, unique: true
      index [:pallet_id, :pallet_number, :pallet_sequence_number], name: :pallet_sequences_unique_idx, unique: true
      index [:pallet_id], name: :pseq_pallet_id_idx
    end
    pgt_created_at(:pallet_sequences,
                   :created_at,
                   function_name: :pgt_pallet_sequences_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:pallet_sequences,
                   :updated_at,
                   function_name: :pgt_pallet_sequences_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pallet_sequences', true, true, '{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:pallet_sequences, :audit_trigger_row)
    drop_trigger(:pallet_sequences, :audit_trigger_stm)

    drop_trigger(:pallet_sequences, :set_created_at)
    drop_function(:pgt_pallet_sequences_set_created_at)
    drop_trigger(:pallet_sequences, :set_updated_at)
    drop_function(:pgt_pallet_sequences_set_updated_at)
    drop_table(:pallet_sequences)

    drop_trigger(:pallets, :audit_trigger_row)
    drop_trigger(:pallets, :audit_trigger_stm)

    drop_trigger(:pallets, :set_created_at)
    drop_function(:pgt_pallets_set_created_at)
    drop_trigger(:pallets, :set_updated_at)
    drop_function(:pgt_pallets_set_updated_at)
    drop_table(:pallets)
  end
end
