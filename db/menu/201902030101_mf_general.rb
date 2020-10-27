Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_program 'General', functional_area: 'Masterfiles'
    add_program_function 'UOMs', functional_area: 'Masterfiles', program: 'General', url: '/list/uoms'
    add_program_function 'List Masterfile Variants', functional_area: 'Masterfiles', program: 'General', url: '/masterfiles/general/masterfile_variants/list_masterfile_variants', seq: 2
  end

  down do
    drop_program 'General', functional_area: 'Masterfiles'
  end
end
