Sequel.migration do
  up do
    alter_table(:cultivar_groups) do
      add_foreign_key :commodity_id, :commodities, null: false
    end

    alter_table(:pallet_sequences) do
      add_column :sell_by_code, String
      add_column :product_chars, String
    end
  end

  down do
    alter_table(:cultivar_groups) do
      drop_column :commodity_id
    end

    alter_table(:pallet_sequences) do
      drop_column :sell_by_code
      drop_column :product_chars
    end
  end
end
