Sequel.migration do
  up do
    extension :pg_triggers
    # --- cargo_temperatures
    create_table(:cargo_temperatures, ignore_index_errors: true) do
      primary_key :id
      String :temperature_code, null: false
      String :description
      BigDecimal :set_point_temperature
      BigDecimal :load_temperature

      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:temperature_code], name: :temperature_unique_code, unique: true
    end

    pgt_created_at(:cargo_temperatures,
                   :created_at,
                   function_name: :cargo_temperatures_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:cargo_temperatures,
                   :updated_at,
                   function_name: :cargo_temperatures_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('cargo_temperatures', true, true, '{updated_at}'::text[]);"

    # --- container_stack_types
    create_table(:container_stack_types, ignore_index_errors: true) do
      primary_key :id
      String :stack_type_code, null: false
      String :description

      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:stack_type_code], name: :stack_type_unique_code, unique: true
    end

    pgt_created_at(:container_stack_types,
                   :created_at,
                   function_name: :container_stack_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:container_stack_types,
                   :updated_at,
                   function_name: :container_stack_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('container_stack_types', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for cargo_temperatures table.
    drop_trigger(:container_stack_types, :audit_trigger_row)
    drop_trigger(:container_stack_types, :audit_trigger_stm)

    drop_trigger(:container_stack_types, :set_created_at)
    drop_function(:container_stack_types_set_created_at)
    drop_trigger(:container_stack_types, :set_updated_at)
    drop_function(:container_stack_types_set_updated_at)
    drop_table(:container_stack_types)


    # Drop logging for cargo_temperatures table.
    drop_trigger(:cargo_temperatures, :audit_trigger_row)
    drop_trigger(:cargo_temperatures, :audit_trigger_stm)

    drop_trigger(:cargo_temperatures, :set_created_at)
    drop_function(:cargo_temperatures_set_created_at)
    drop_trigger(:cargo_temperatures, :set_updated_at)
    drop_function(:cargo_temperatures_set_updated_at)
    drop_table(:cargo_temperatures)
  end
end
