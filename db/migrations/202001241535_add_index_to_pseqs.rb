Sequel.migration do
  up do
    alter_table(:pallet_sequences) do
      add_index :pallet_id, name: :pseq_pallet_id_idx
    end
  end

  down do
    alter_table(:pallet_sequences) do
      drop_index :pallet_id, name: :pseq_pallet_id_idx
    end
  end
end
