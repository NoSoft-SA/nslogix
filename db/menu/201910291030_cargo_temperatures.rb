Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_program_function 'Cargo Temperature', functional_area: 'Masterfiles', program: 'Shipping', url: '/list/cargo_temperatures', seq: 8
  end

  down do
    drop_program_function 'Cargo Temperature', functional_area: 'Masterfiles', program: 'Shipping'
  end
end