require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:farm_groups, ignore_index_errors: true) do
      primary_key :id
      foreign_key :owner_party_role_id, :party_roles, type: :integer, null: false
      String :farm_group_code, size: 255, null: false
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:farm_group_code], name: :farm_groups_unique_code, unique: true
    end

    pgt_created_at(:farm_groups,
                   :created_at,
                   function_name: :farm_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:farm_groups,
                   :updated_at,
                   function_name: :farm_groups_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('farm_groups', true, true, '{updated_at}'::text[]);"

    create_table(:farms, ignore_index_errors: true) do
      primary_key :id
      foreign_key :owner_party_role_id, :party_roles, type: :integer, null: false
      foreign_key :pdn_region_id, :production_regions, type: :integer, null: false
      foreign_key :farm_group_id, :farm_groups, type: :integer
      # foreign_key :puc_id, :pucs, type: :integer, null: false
      String :farm_code, size: 255, null: false
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:farm_code], name: :farms_unique_code, unique: true
    end

    pgt_created_at(:farms,
                   :created_at,
                   function_name: :farms_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:farms,
                   :updated_at,
                   function_name: :farms_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('farms', true, true, '{updated_at}'::text[]);"

    create_table(:pucs, ignore_index_errors: true) do
      primary_key :id
      String :puc_code, size: 255, null: false
      String :gap_code
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:puc_code], name: :pucs_unique_code, unique: true
    end

    pgt_created_at(:pucs,
                   :created_at,
                   function_name: :pucs_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:pucs,
                   :updated_at,
                   function_name: :pucs_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('pucs', true, true, '{updated_at}'::text[]);"

    create_table(:farms_pucs, ignore_index_errors: true) do
      foreign_key :puc_id, :pucs, type: :integer, null: false
      foreign_key :farm_id, :farms, type: :integer, null: false

      index [:puc_id, :farm_id], name: :farms_pucs_idx, unique: true
    end

    create_table(:orchards, ignore_index_errors: true) do
      primary_key :id
      foreign_key :farm_id, :farms, type: :integer, null: false
      foreign_key :puc_id, :pucs, type: :integer, null: false
      String :orchard_code, size: 255, null: false
      String :description
      column :cultivar_ids, 'int[]'
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:orchard_code], name: :orchards_unique_code, unique: true
    end

    pgt_created_at(:orchards,
                   :created_at,
                   function_name: :orchards_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:orchards,
                   :updated_at,
                   function_name: :orchards_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('orchards', true, true, '{updated_at}'::text[]);"

  end

  down do
    # Drop logging for this table.
    drop_trigger(:orchards, :audit_trigger_row)
    drop_trigger(:orchards, :audit_trigger_stm)

    drop_trigger(:orchards, :set_created_at)
    drop_function(:orchards_set_created_at)
    drop_trigger(:orchards, :set_updated_at)
    drop_function(:orchards_set_updated_at)
    drop_table(:orchards)

    drop_table(:farms_pucs)

    drop_trigger(:pucs, :audit_trigger_row)
    drop_trigger(:pucs, :audit_trigger_stm)

    drop_trigger(:pucs, :set_created_at)
    drop_function(:pucs_set_created_at)
    drop_trigger(:pucs, :set_updated_at)
    drop_function(:pucs_set_updated_at)
    drop_table(:pucs)

    drop_trigger(:farms, :audit_trigger_row)
    drop_trigger(:farms, :audit_trigger_stm)

    drop_trigger(:farms, :set_created_at)
    drop_function(:farms_set_created_at)
    drop_trigger(:farms, :set_updated_at)
    drop_function(:farms_set_updated_at)
    drop_table(:farms)

    drop_trigger(:farm_groups, :audit_trigger_row)
    drop_trigger(:farm_groups, :audit_trigger_stm)

    drop_trigger(:farm_groups, :set_created_at)
    drop_function(:farm_groups_set_created_at)
    drop_trigger(:farm_groups, :set_updated_at)
    drop_function(:farm_groups_set_updated_at)
    drop_table(:farm_groups)
  end
end
