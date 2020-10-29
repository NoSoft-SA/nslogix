require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:programs, ignore_index_errors: true) do
      primary_key :id
      String :program_name, size: 255, null: false
      Integer :program_sequence, default: 0, null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      foreign_key :functional_area_id, :functional_areas, null: false

      index [:functional_area_id], name: :fki_programs_functional_areas
      index [:functional_area_id, :program_name], name: :programs_functional_area_id_program_name_key, unique: true
    end

    alter_table(:programs) do
      set_column_type :program_name, :citext
    end
    pgt_created_at(:programs,
                   :created_at,
                   function_name: :pgt_programs_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:programs,
                   :updated_at,
                   function_name: :pgt_programs_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:programs, :set_created_at)
    drop_function(:pgt_programs_set_created_at)
    drop_trigger(:programs, :set_updated_at)
    drop_function(:pgt_programs_set_updated_at)
    drop_table(:programs)
  end
end
