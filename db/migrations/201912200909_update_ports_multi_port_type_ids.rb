Sequel.migration do
  up do
    alter_table(:ports) do
      add_column :port_type_ids, 'integer[]'
      add_column :voyage_type_ids, 'integer[]'
      drop_column :voyage_type_id
      drop_column :port_type_id
    end

    alter_table(:voyage_ports) do
      add_foreign_key :port_type_id, :port_types, type: :integer, null: false
    end
  end

  down do
    alter_table(:voyage_ports) do
      drop_foreign_key :port_type_id
    end

    alter_table(:ports) do
      add_foreign_key :port_type_id, :port_types, type: :integer
      add_foreign_key :voyage_type_id, :voyage_types, type: :integer
      drop_column :voyage_type_ids
      drop_column :port_type_ids
    end
  end
end
