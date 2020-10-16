require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:grades, ignore_index_errors: true) do
      primary_key :id

      String :grade_code, null: false
      String :description
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:grade_code], name: :grades_unique_code, unique: true
    end

    pgt_created_at(:grades,
                   :created_at,
                   function_name: :grades_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:grades,
                   :updated_at,
                   function_name: :grades_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('grades', true, true, '{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:grades, :audit_trigger_row)
    drop_trigger(:grades, :audit_trigger_stm)

    drop_trigger(:grades, :set_created_at)
    drop_function(:grades_set_created_at)
    drop_trigger(:grades, :set_updated_at)
    drop_function(:grades_set_updated_at)
    drop_table(:grades)
  end
end

