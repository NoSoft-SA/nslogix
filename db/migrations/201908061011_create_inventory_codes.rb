require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:inventory_codes, ignore_index_errors: true) do
      primary_key :id

      String :inventory_code, null: false
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:inventory_code], name: :inventory_codes_unique_code, unique: true
    end
    pgt_created_at(:inventory_codes,
                   :created_at,
                   function_name: :pgt_inventory_codes_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:inventory_codes,
                   :updated_at,
                   function_name: :pgt_inventory_codes_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('inventory_codes', true, true, '{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:inventory_codes, :audit_trigger_row)
    drop_trigger(:inventory_codes, :audit_trigger_stm)

    drop_trigger(:inventory_codes, :set_created_at)
    drop_function(:pgt_inventory_codes_set_created_at)
    drop_trigger(:inventory_codes, :set_updated_at)
    drop_function(:pgt_inventory_codes_set_updated_at)
    drop_table(:inventory_codes)
  end
end

