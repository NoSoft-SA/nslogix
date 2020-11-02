require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:pallet_bases, ignore_index_errors: true) do
      primary_key :id
      String :pallet_base_code, size: 255, null: false
      String :description
      Integer :length
      Integer :width
      String :edi_in_pallet_base
      String :edi_out_pallet_base
      Integer :cartons_per_layer
      BigDecimal :material_mass, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pallet_base_code], name: :pallet_bases_unique_code, unique: true
    end
    pgt_created_at(:pallet_bases,
                   :created_at,
                   function_name: :pgt_pallet_bases_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:pallet_bases,
                   :updated_at,
                   function_name: :pgt_pallet_bases_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pallet_bases', true, true, '{updated_at}'::text[]);"

    create_table(:pallet_stack_types, ignore_index_errors: true) do
      primary_key :id
      String :stack_type_code, size: 255, null: false
      String :description
      Integer :stack_height, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:stack_type_code], name: :pallet_stack_types_unique_code, unique: true
    end
    pgt_created_at(:pallet_stack_types,
                   :created_at,
                   function_name: :pgt_pallet_stack_types_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:pallet_stack_types,
                   :updated_at,
                   function_name: :pgt_pallet_stack_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pallet_stack_types', true, true, '{updated_at}'::text[]);"

    create_table(:pallet_formats, ignore_index_errors: true) do
      primary_key :id
      String :description, null: false
      foreign_key :pallet_base_id, :pallet_bases, type: :integer, null: false
      foreign_key :pallet_stack_type_id, :pallet_stack_types, type: :integer, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pallet_base_id, :pallet_stack_type_id], name: :pallet_formats_idx, unique: true
    end
    pgt_created_at(:pallet_formats,
                   :created_at,
                   function_name: :pgt_pallet_formats_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:pallet_formats,
                   :updated_at,
                   function_name: :pgt_pallet_formats_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pallet_formats', true, true, '{updated_at}'::text[]);"

    create_table(:cartons_per_pallet, ignore_index_errors: true) do
      primary_key :id
      String :description
      foreign_key :pallet_format_id, :pallet_formats, type: :integer, null: false
      foreign_key :basic_pack_id, :basic_pack_codes, type: :integer, null: false
      Integer :cartons_per_pallet, null: false
      Integer :layers_per_pallet, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pallet_format_id, :basic_pack_id], name: :cartons_per_pallet_idx, unique: true
    end
    pgt_created_at(:cartons_per_pallet,
                   :created_at,
                   function_name: :pgt_cartons_per_pallet_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:cartons_per_pallet,
                   :updated_at,
                   function_name: :pgt_cartons_per_pallet_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('cartons_per_pallet', true, true, '{updated_at}'::text[]);"

  end

  down do
    # Drop logging for this table.
    drop_trigger(:cartons_per_pallet, :audit_trigger_row)
    drop_trigger(:cartons_per_pallet, :audit_trigger_stm)

    drop_trigger(:cartons_per_pallet, :set_created_at)
    drop_function(:pgt_cartons_per_pallet_set_created_at)
    drop_trigger(:cartons_per_pallet, :set_updated_at)
    drop_function(:pgt_cartons_per_pallet_set_updated_at)
    drop_table(:cartons_per_pallet)

    drop_trigger(:pallet_formats, :audit_trigger_row)
    drop_trigger(:pallet_formats, :audit_trigger_stm)

    drop_trigger(:pallet_formats, :set_created_at)
    drop_function(:pgt_pallet_formats_set_created_at)
    drop_trigger(:pallet_formats, :set_updated_at)
    drop_function(:pgt_pallet_formats_set_updated_at)
    drop_table(:pallet_formats)

    drop_trigger(:pallet_stack_types, :audit_trigger_row)
    drop_trigger(:pallet_stack_types, :audit_trigger_stm)

    drop_trigger(:pallet_stack_types, :set_created_at)
    drop_function(:pgt_pallet_stack_types_set_created_at)
    drop_trigger(:pallet_stack_types, :set_updated_at)
    drop_function(:pgt_pallet_stack_types_set_updated_at)
    drop_table(:pallet_stack_types)

    drop_trigger(:pallet_bases, :audit_trigger_row)
    drop_trigger(:pallet_bases, :audit_trigger_stm)

    drop_trigger(:pallet_bases, :set_created_at)
    drop_function(:pgt_pallet_bases_set_created_at)
    drop_trigger(:pallet_bases, :set_updated_at)
    drop_function(:pgt_pallet_bases_set_updated_at)
    drop_table(:pallet_bases)
  end
end
