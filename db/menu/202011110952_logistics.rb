Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_functional_area 'Logistics'
    add_program 'Logistics', functional_area: 'Logistics', seq: 1
    # add_program_function 'New Pallet', functional_area: 'Logistics', program: 'Logistics', url: '/logistics/logistics/pallets/new', seq: 1
    add_program_function 'List Pallets', functional_area: 'Logistics', program: 'Logistics', url: '/list/pallets', seq: 2
    # add_program_function 'Search Pallets', functional_area: 'Logistics', program: 'Logistics', url: '/search/pallets', seq: 3
  end

  down do
    # drop_program_function 'Search Pallet', functional_area: 'Logistics', program: 'Logistics'
    # drop_program_function 'List Pallet', functional_area: 'Logistics', program: 'Logistics'
    # drop_program_function 'New Pallet', functional_area: 'Logistics', program: 'Logistics'
    # drop_program 'Logistics', functional_area: 'Logistics'
    drop_functional_area 'Logistics'
  end
end