require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers

    create_table(:pallet_quarantine, ignore_index_errors: true) do
      primary_key :id
      String :pallet_number, null: false
      String :flow_type, null: false
      Jsonb :record_data, null: false
      Jsonb :record_errors, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:pallet_number], name: :pallet_quarantine_idx, unique: true

  end
  pgt_created_at(:pallet_quarantine,
                 :created_at,
                 function_name: :pgt_pallet_quarantine_set_created_at,
                 trigger_name: :set_created_at)
  pgt_updated_at(:pallet_quarantine,
                 :updated_at,
                 function_name: :pgt_pallet_quarantine_set_updated_at,
                 trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:pallet_quarantine, :set_created_at)
    drop_function(:pgt_pallet_quarantine_set_created_at)
    drop_trigger(:pallet_quarantine, :set_updated_at)
    drop_function(:pgt_pallet_quarantine_set_updated_at)
    drop_table(:pallet_quarantine)
  end
end
