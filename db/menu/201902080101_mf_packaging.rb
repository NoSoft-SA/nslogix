Crossbeams::MenuMigrations::Migrator.migration('Nslogix') do
  up do
    add_program 'Packaging', functional_area: 'Masterfiles'
    add_program_function 'Pallet Bases', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pallet_bases', seq: 1
    add_program_function 'Pallet Stack Types', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pallet_stack_types', seq: 2

    add_program_function 'Basic', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/basic_pack_codes', seq: 3, group: 'Pack codes'
    add_program_function 'Standard', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/standard_pack_codes', seq: 4, group: 'Pack codes'
    add_program_function 'STD Product Weights', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/standard_product_weights', seq: 5, group: 'Pack codes'

    add_program_function 'Pallet Formats', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pallet_formats', seq: 6
    add_program_function 'Cartons Per Pallet', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/cartons_per_pallet', seq: 7
    add_program_function 'Search Cartons Per Pallet', functional_area: 'Masterfiles', program: 'Packaging', url: '/search/cartons_per_pallet', seq: 8

    add_program_function 'PM Types', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pm_types', seq: 9, group: 'Bill of Materials'
    add_program_function 'PM Subtypes', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pm_subtypes', seq: 10, group: 'Bill of Materials'
    add_program_function 'PM Products', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pm_products', seq: 11, group: 'Bill of Materials'
    add_program_function 'PM BOMs', functional_area: 'Masterfiles', program: 'Packaging', url: '/list/pm_boms', seq: 12, group: 'Bill of Materials'
    add_program_function 'Search PM BOMs Products', functional_area: 'Masterfiles', program: 'Packaging', url: '/search/pm_boms_products', seq: 13, group: 'Bill of Materials'
  end

  down do
    drop_program 'Packaging', functional_area: 'Masterfiles'
  end
end
