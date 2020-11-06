require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:std_fruit_size_counts, ignore_index_errors: true) do
      primary_key :id
      foreign_key :commodity_id, :commodities, null: false
      foreign_key :uom_id, :uoms, null: false
      String :size_count_description
      String :marketing_size_range_mm
      String :marketing_weight_range
      String :size_count_interval_group
      Integer :size_count_value, null: false
      Integer :minimum_size_mm
      Integer :maximum_size_mm
      Integer :average_size_mm
      Float :minimum_weight_gm
      Float :maximum_weight_gm
      Float :average_weight_gm
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:commodity_id, :size_count_value]
      index [:commodity_id], name: :fki_std_fruit_size_counts_commodities
    end
    pgt_created_at(:std_fruit_size_counts,
                   :created_at,
                   function_name: :pgt_std_fruit_size_counts_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:std_fruit_size_counts,
                   :updated_at,
                   function_name: :pgt_std_fruit_size_counts_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:basic_pack_codes, ignore_index_errors: true) do
      primary_key :id
      String :basic_pack_code, null: false
      String :description
      Integer :length_mm
      Integer :width_mm
      Integer :height_mm
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :basic_pack_code, name: :basic_pack_codes_unique_code
    end
    pgt_created_at(:basic_pack_codes,
                   :created_at,
                   function_name: :pgt_basic_pack_codes_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:basic_pack_codes,
                   :updated_at,
                   function_name: :pgt_basic_pack_codes_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:standard_pack_codes, ignore_index_errors: true) do
      primary_key :id
      foreign_key :basic_pack_code_id, :basic_pack_codes, null: false
      String :standard_pack_code, null: false
      String :description
      String :std_pack_label_code
      BigDecimal :material_mass, null: false
      TrueClass :use_size_ref_for_edi, default: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique :standard_pack_code, name: :standard_pack_codes_unique_code
    end
    pgt_created_at(:standard_pack_codes,
                   :created_at,
                   function_name: :pgt_standard_pack_codes_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:standard_pack_codes,
                   :updated_at,
                   function_name: :pgt_standard_pack_codes_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:fruit_actual_counts_for_packs, ignore_index_errors: true) do
      primary_key :id
      foreign_key :std_fruit_size_count_id, :std_fruit_size_counts, null: false
      foreign_key :basic_pack_code_id, :basic_pack_codes, null: false
      column :standard_pack_code_ids, 'integer[]'
      column :size_reference_ids, 'integer[]'

      Integer :actual_count_for_pack, null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:std_fruit_size_count_id, :basic_pack_code_id], name: :fruit_actual_counts_for_packs_idx
      index [:std_fruit_size_count_id], name: :fki_fruit_actual_counts_for_packs_std_fruit_size_counts
      index [:basic_pack_code_id], name: :fki_fruit_actual_counts_for_packs_basic_pack_codes
      index [:standard_pack_code_id], name: :fki_fruit_actual_counts_for_packs_standard_pack_codes
    end
    pgt_created_at(:fruit_actual_counts_for_packs,
                   :created_at,
                   function_name: :pgt_fruit_actual_counts_for_packs_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:fruit_actual_counts_for_packs,
                   :updated_at,
                   function_name: :pgt_fruit_actual_counts_for_packs_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:fruit_size_references, ignore_index_errors: true) do
      primary_key :id
      String :size_reference, null: false
      String :edi_out_code
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique [:size_reference], name: :fruit_size_references_idx
    end
    pgt_created_at(:fruit_size_references,
                   :created_at,
                   function_name: :pgt_fruit_size_references_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:fruit_size_references,
                   :updated_at,
                   function_name: :pgt_fruit_size_references_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:fruit_size_references, :set_created_at)
    drop_function(:pgt_fruit_size_references_set_created_at)
    drop_trigger(:fruit_size_references, :set_updated_at)
    drop_function(:pgt_fruit_size_references_set_updated_at)
    drop_table(:fruit_size_references)

    drop_trigger(:fruit_actual_counts_for_packs, :set_created_at)
    drop_function(:pgt_fruit_actual_counts_for_packs_set_created_at)
    drop_trigger(:fruit_actual_counts_for_packs, :set_updated_at)
    drop_function(:pgt_fruit_actual_counts_for_packs_set_updated_at)
    drop_table(:fruit_actual_counts_for_packs)

    drop_trigger(:standard_pack_codes, :set_created_at)
    drop_function(:pgt_standard_pack_codes_set_created_at)
    drop_trigger(:standard_pack_codes, :set_updated_at)
    drop_function(:pgt_standard_pack_codes_set_updated_at)
    drop_table(:standard_pack_codes)

    drop_trigger(:basic_pack_codes, :set_created_at)
    drop_function(:pgt_basic_pack_codes_set_created_at)
    drop_trigger(:basic_pack_codes, :set_updated_at)
    drop_function(:pgt_basic_pack_codes_set_updated_at)
    drop_table(:basic_pack_codes)

    drop_trigger(:std_fruit_size_counts, :set_created_at)
    drop_function(:pgt_std_fruit_size_counts_set_created_at)
    drop_trigger(:std_fruit_size_counts, :set_updated_at)
    drop_function(:pgt_std_fruit_size_counts_set_updated_at)
    drop_table(:std_fruit_size_counts)
  end
end
