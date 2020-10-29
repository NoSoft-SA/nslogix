require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:customer_varieties, ignore_index_errors: true) do
      primary_key :id
      foreign_key :variety_as_customer_variety_id, :marketing_varieties, type: :integer, null: false
      foreign_key :packed_tm_group_id, :target_market_groups, type: :integer, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:variety_as_customer_variety_id, :packed_tm_group_id], name: :customer_varieties_idx, unique: true
    end
    pgt_created_at(:customer_varieties,
                   :created_at,
                   function_name: :customer_varieties_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:customer_varieties,
                   :updated_at,
                   function_name: :customer_varieties_set_updated_at,
                   trigger_name: :set_updated_at)
    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('customer_varieties', true, true, '{updated_at}'::text[]);"

    create_table(:customer_variety_varieties, ignore_index_errors: true) do
      primary_key :id
      foreign_key :customer_variety_id, :customer_varieties, type: :integer, null: false
      foreign_key :marketing_variety_id, :marketing_varieties, type: :integer, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:customer_variety_id, :marketing_variety_id], name: :customer_variety_varieties_idx, unique: true
    end
    pgt_created_at(:customer_variety_varieties,
                   :created_at,
                   function_name: :customer_variety_varieties_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:customer_variety_varieties,
                   :updated_at,
                   function_name: :customer_variety_varieties_set_updated_at,
                   trigger_name: :set_updated_at)
    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('customer_variety_varieties', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:customer_variety_varieties, :audit_trigger_row)
    drop_trigger(:customer_variety_varieties, :audit_trigger_stm)

    drop_trigger(:customer_variety_varieties, :set_created_at)
    drop_function(:customer_variety_varieties_set_created_at)
    drop_trigger(:customer_variety_varieties, :set_updated_at)
    drop_function(:customer_variety_varieties_set_updated_at)
    drop_table(:customer_variety_varieties)

    drop_trigger(:customer_varieties, :audit_trigger_row)
    drop_trigger(:customer_varieties, :audit_trigger_stm)

    drop_trigger(:customer_varieties, :set_created_at)
    drop_function(:customer_varieties_set_created_at)
    drop_trigger(:customer_varieties, :set_updated_at)
    drop_function(:customer_varieties_set_updated_at)
    drop_table(:customer_varieties)
  end
end
