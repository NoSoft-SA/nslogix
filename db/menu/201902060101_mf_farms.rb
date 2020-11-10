Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_program 'Farms', functional_area: 'Masterfiles'
    add_program_function 'Production Regions', functional_area: 'Masterfiles', program: 'Farms', url: '/list/production_regions'
    add_program_function 'PUCs', functional_area: 'Masterfiles', program: 'Farms', url: '/list/pucs', seq: 2
    add_program_function 'Farm Groups', functional_area: 'Masterfiles', program: 'Farms', url: '/list/farm_groups', seq: 3
    add_program_function 'Farms', functional_area: 'Masterfiles', program: 'Farms', url: '/list/farms', seq: 4
    add_program_function 'Orchards', functional_area: 'Masterfiles', program: 'Farms', url: '/list/orchards', seq: 5
  end

  down do
    drop_program 'Farms', functional_area: 'Masterfiles'
  end
end
