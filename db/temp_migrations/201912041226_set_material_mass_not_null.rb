Sequel.migration do
  up do
    run "UPDATE pallet_bases SET material_mass = 0 WHERE material_mass IS NULL;"
    alter_table(:pallet_bases) do
      set_column_not_null :material_mass
    end
  end

  down do
    alter_table(:pallet_bases) do
      set_column_allow_null :material_mass
    end
  end
end
