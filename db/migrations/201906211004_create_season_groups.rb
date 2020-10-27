require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:season_groups, ignore_index_errors: true) do
      primary_key :id
      String :season_group_code, null: false
      String :description
      Integer :season_group_year
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:season_group_code], name: :season_groups_unique_code, unique: true
    end

    pgt_created_at(:season_groups,
                   :created_at,
                   function_name: :season_groups_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:season_groups,
                   :updated_at,
                   function_name: :season_groups_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('season_groups', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:season_groups, :audit_trigger_row)
    drop_trigger(:season_groups, :audit_trigger_stm)

    drop_trigger(:season_groups, :set_created_at)
    drop_function(:season_groups_set_created_at)
    drop_trigger(:season_groups, :set_updated_at)
    drop_function(:season_groups_set_updated_at)
    drop_table(:season_groups)
  end
end
