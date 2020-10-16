Sequel.migration do
  up do
    alter_table(:pallet_sequences) do
      drop_constraint :pallet_sequences_customer_variety_variety_id_fkey
      rename_column :customer_variety_variety_id, :customer_variety_id
      add_foreign_key [:customer_variety_id], :customer_varieties, name: :pallet_sequences_customer_variety_id_fkey
    end
  end

  down do
     alter_table(:pallet_sequences) do
      drop_constraint :pallet_sequences_customer_variety_id_fkey
      rename_column :customer_variety_id, :customer_variety_variety_id
      add_foreign_key [:customer_variety_variety_id], :customer_variety_varieties, name: :pallet_sequences_customer_variety_variety_id_fkey
    end
  end
end
