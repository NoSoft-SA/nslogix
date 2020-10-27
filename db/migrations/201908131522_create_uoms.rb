require 'sequel_postgresql_triggers' # Uncomment this line for created_at and updated_at triggers.
Sequel.migration do
  up do
    create_table(:uom_types, ignore_index_errors: true) do
      primary_key :id
      String :code, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:code], name: :uom_types_unique_code, unique: true
    end
    pgt_created_at(:uom_types,
                   :created_at,
                   function_name: :uom_types_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:uom_types,
                   :updated_at,
                   function_name: :uom_types_set_updated_at,
                   trigger_name: :set_updated_at)

    create_table(:uoms, ignore_index_errors: true) do
      primary_key :id
      foreign_key :uom_type_id, :uom_types, null: false, key: [:id]
      String :uom_code, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:uom_code, :uom_type_id], name: :fki_uom_codes_uom_types, unique: true
    end
    pgt_created_at(:uoms,
                   :created_at,
                   function_name: :uoms_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:uoms,
                   :updated_at,
                   function_name: :uoms_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:uoms, :set_created_at)
    drop_function(:uoms_set_created_at)
    drop_trigger(:uoms, :set_updated_at)
    drop_function(:uoms_set_updated_at)
    drop_table(:uoms)

    drop_trigger(:uom_types, :set_created_at)
    drop_function(:uom_types_set_created_at)
    drop_trigger(:uom_types, :set_updated_at)
    drop_function(:uom_types_set_updated_at)
    drop_table(:uom_types)
  end
end
