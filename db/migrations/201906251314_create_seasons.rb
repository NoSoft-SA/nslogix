require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:seasons, ignore_index_errors: true) do
      primary_key :id
      foreign_key :season_group_id, :season_groups, type: :integer, null: false
      foreign_key :commodity_id, :commodities, type: :integer, null: false
      String :season_code, null: false
      String :description
      Integer :season_year, null: false
      Date :start_date, null: false
      Date :end_date, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:season_code], name: :seasons_unique_code, unique: true
    end
    pgt_created_at(:seasons,
                   :created_at,
                   function_name: :pgt_seasons_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:seasons,
                   :updated_at,
                   function_name: :pgt_seasons_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('seasons', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:seasons, :audit_trigger_row)
    drop_trigger(:seasons, :audit_trigger_stm)

    drop_trigger(:seasons, :set_created_at)
    drop_function(:pgt_seasons_set_created_at)
    drop_trigger(:seasons, :set_updated_at)
    drop_function(:pgt_seasons_set_updated_at)
    drop_table(:seasons)
  end
end
