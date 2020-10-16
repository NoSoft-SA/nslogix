Sequel.migration do
  up do
    alter_table(:standard_pack_codes) do
      add_column :std_pack_label_code, String
    end

    alter_table(:std_fruit_size_counts) do
      add_foreign_key :uom_id, :uoms, type: :integer, null: false
    end
  end

  down do
    alter_table(:standard_pack_codes) do
      drop_column :std_pack_label_code
    end

    alter_table(:std_fruit_size_counts) do
      drop_column :uom_id
    end
  end
end
