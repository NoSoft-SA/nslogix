Sequel.migration do
  up do
    run <<~SQL
      DROP VIEW IF EXISTS public.vw_pallets;
      CREATE VIEW public.vw_pallets AS
        SELECT
            pallets.id AS pallet_id,
            fn_current_status ('pallets', pallets.id) AS pallet_status,
            pallets.pallet_number,
            --
            pallets.in_stock,
            pallets.stock_created_at,
            --
            pallets.exit_ref,
            --
            pallets.pallet_format_id,
            pallet_bases.pallet_base_code,
            pallet_stack_types.stack_type_code,
            --
            pallets.carton_quantity AS pallet_carton_quantity,
            --
            pallets.build_status,
            pallets.phc,
            pallets.intake_created_at,
            pallets.first_cold_storage_at,
            pallets.first_cold_storage_at::date AS first_cold_storage_date,
            --
            pallets.nett_weight,
            pallets.gross_weight,
            pallets.gross_weight_measured_at,
            pallets.palletized,
            pallets.partially_palletized,
            pallets.palletized_at,
            pallets.palletized_at::date AS palletized_date,
            pallets.partially_palletized_at,
            pallets.partially_palletized_at::date AS partially_palletized_date,
            --
            pallet_ages.pallet_age,
            pallet_ages.inspection_age,
            pallet_ages.stock_age,
            pallet_ages.cold_age,
            pallet_ages.ambient_age,
            pallet_ages.reinspection_age,
            pallet_ages.pack_to_inspect_age,
            pallet_ages.inspect_to_cold_age,
            pallet_ages.inspect_to_exit_warm_age,
            --
            pallets.cooled,
            pallets.temp_tail,
            --
            pallets.allocated,
            pallets.allocated_at,
            pallets.shipped,
            pallets.shipped_at,
            pallets.shipped_at::date AS shipped_date,
            --
            pallets.inspected,
            pallets.govt_first_inspection_at,
            pallets.govt_first_inspection_at::date AS govt_first_inspection_date,
            pallets.govt_reinspection_at,
            pallets.govt_reinspection_at::date AS govt_reinspection_date,
            --
            pallets.internal_inspection_at,
            pallets.internal_reinspection_at,
            pallets.govt_inspection_passed,
            pallets.internal_inspection_passed,
            pallets.reinspected,
            --
            pallets.edi_in_transaction_id,
            edi_in_transactions.file_name AS edi_in_file,

            COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at)::date AS inspection_date,
            pallets.repacked AS pallet_repacked,
            pallets.repacked_at AS pallet_repacked_at,
            pallets.repacked_at::date AS pallet_repacked_date,
            --
            pallets.scrapped,
            pallets.scrapped_at,
            pallets.scrapped_at::date AS scrapped_date,
            --
            pallets.active,
            pallets.created_at,
            pallets.updated_at
        FROM
            pallets
            LEFT JOIN fn_pallet_ages(pallets.id) pallet_ages ON pallets.id = pallet_ages.id
            LEFT JOIN pallet_formats ON pallet_formats.id = pallets.pallet_format_id
            LEFT JOIN pallet_bases ON pallet_bases.id = pallet_formats.pallet_base_id
            LEFT JOIN pallet_stack_types ON pallet_stack_types.id = pallet_formats.pallet_stack_type_id
            --
            LEFT JOIN edi_in_transactions ON edi_in_transactions.id = pallets.edi_in_transaction_id;
        ALTER TABLE public.vw_pallets OWNER TO postgres;
    SQL
  end

  down do
    run <<~SQL
      DROP VIEW IF EXISTS public.vw_pallets;
    SQL
  end
end
