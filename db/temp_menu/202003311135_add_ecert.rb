Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_functional_area 'Finished Goods'
    add_program 'eCert', functional_area: 'Finished Goods', seq: 4
    add_program_function 'List eCert Agreements', functional_area: 'Finished Goods', program: 'eCert', url: '/list/ecert_agreements', seq: 2
    add_program_function 'List eCert Tracking Units', functional_area: 'Finished Goods', program: 'eCert', url: '/list/ecert_tracking_units', seq: 5
  end

  down do
    # drop_program 'eCert', functional_area: 'Finished Goods'
    drop_functional_area 'Finished Goods'
  end
end
