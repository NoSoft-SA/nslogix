Sequel.migration do
  up do
    alter_table(:organizations) do
      drop_column :variants
    end

    alter_table(:masterfile_variants) do
      rename_column :code, :variant_code
    end
  end

  down do
    alter_table(:masterfile_variants) do
      rename_column :variant_code, :code
    end

    alter_table(:organizations) do
      add_column :variants, 'text[]'
    end
  end
end
