Sequel.migration do
  up do
    alter_table(:pallet_sequences) do
      set_column_allow_null :pallet_id
      add_column :grade_id, Integer, null: false
      add_column :scrapped_from_pallet_id, Integer
      add_column :removed_from_pallet, TrueClass, default: false
      add_column :removed_from_pallet_id, Integer
      add_column :removed_from_pallet_at, DateTime
    end
  end

  down do
    alter_table(:pallet_sequences) do
      set_column_not_null :pallet_id
      drop_column :grade_id
      drop_column :scrapped_from_pallet_id
      drop_column :removed_from_pallet
      drop_column :removed_from_pallet_id
      drop_column :removed_from_pallet_at
    end
  end
end
