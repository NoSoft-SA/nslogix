Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_program_function 'List Masterfile Variants', functional_area: 'Masterfiles', program: 'General', url: '/masterfiles/general/masterfile_variants/list_masterfile_variants', seq: 2
  end

  down do
    drop_program_function 'List Masterfile Variants', functional_area: 'Masterfiles', program: 'General'
  end
end
