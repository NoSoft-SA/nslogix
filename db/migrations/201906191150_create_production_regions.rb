require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:production_regions, ignore_index_errors: true) do
      primary_key :id
      String :production_region_code, null: false
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:production_region_code], name: :production_regions_unique_code, unique: true
    end
    pgt_created_at(:production_regions,
                   :created_at,
                   function_name: :pgt_production_regions_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:production_regions,
                   :updated_at,
                   function_name: :pgt_production_regions_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('production_regions', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:production_regions, :audit_trigger_row)
    drop_trigger(:production_regions, :audit_trigger_stm)

    drop_trigger(:production_regions, :set_created_at)
    drop_function(:pgt_production_regions_set_created_at)
    drop_trigger(:production_regions, :set_updated_at)
    drop_function(:pgt_production_regions_set_updated_at)
    drop_table(:production_regions)
  end
end
