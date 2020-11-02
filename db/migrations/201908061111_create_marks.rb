require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:marks, ignore_index_errors: true) do
      primary_key :id

      String :mark_code, null: false
      String :description
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:mark_code], name: :marks_unique_code, unique: true
    end
    pgt_created_at(:marks,
                   :created_at,
                   function_name: :pgt_marks_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:marks,
                   :updated_at,
                   function_name: :pgt_marks_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('marks', true, true, '{updated_at}'::text[]);"
  end

  down do
    drop_trigger(:marks, :audit_trigger_row)
    drop_trigger(:marks, :audit_trigger_stm)

    drop_trigger(:marks, :set_created_at)
    drop_function(:pgt_marks_set_created_at)
    drop_trigger(:marks, :set_updated_at)
    drop_function(:pgt_marks_set_updated_at)
    drop_table(:marks)
  end
end
