require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:treatment_types, ignore_index_errors: true) do
      primary_key :id

      String :treatment_type_code, null: false
      String :description
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:treatment_type_code], name: :treatment_types_unique_code, unique: true
    end

    pgt_created_at(:treatment_types,
                   :created_at,
                   function_name: :treatment_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:treatment_types,
                   :updated_at,
                   function_name: :treatment_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('treatment_types', true, true, '{updated_at}'::text[]);"

    create_table(:treatments, ignore_index_errors: true) do
      primary_key :id
      foreign_key :treatment_type_id, :treatment_types, type: :integer, null: false
      String :treatment_code, size: 255, null: false
      String :description
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:treatment_code], name: :treatments_unique_code, unique: true
    end

    pgt_created_at(:treatments,
                   :created_at,
                   function_name: :treatments_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:treatments,
                   :updated_at,
                   function_name: :treatments_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('treatments', true, true, '{updated_at}'::text[]);"
  end

  down do

    drop_trigger(:treatments, :audit_trigger_row)
    drop_trigger(:treatments, :audit_trigger_stm)

    drop_trigger(:treatments, :set_created_at)
    drop_function(:treatments_set_created_at)
    drop_trigger(:treatments, :set_updated_at)
    drop_function(:treatments_set_updated_at)
    drop_table(:treatments)

    drop_trigger(:treatment_types, :audit_trigger_row)
    drop_trigger(:treatment_types, :audit_trigger_stm)

    drop_trigger(:treatment_types, :set_created_at)
    drop_function(:treatment_types_set_created_at)
    drop_trigger(:treatment_types, :set_updated_at)
    drop_function(:treatment_types_set_updated_at)
    drop_table(:treatment_types)
  end
end
