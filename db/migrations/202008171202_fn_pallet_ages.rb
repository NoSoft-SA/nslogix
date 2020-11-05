Sequel.migration do
  up do
    run <<~SQL
      DROP FUNCTION IF EXISTS fn_pallet_ages (integer);
      CREATE FUNCTION fn_pallet_ages (in_id integer)
          RETURNS TABLE (
                            id int,
                            pallet_age double precision,
                            inspection_age double precision,
                            stock_age double precision,
                            cold_age double precision,
                            ambient_age double precision,
                            reinspection_age double precision,
                            pack_to_inspect_age double precision,
                            inspect_to_cold_age double precision,
                            inspect_to_exit_warm_age double precision
                        )
          LANGUAGE plpgsql
      AS $$
      BEGIN
          RETURN QUERY
              SELECT
                  pallets.id,
                  fn_calc_age_days(
                          pallets.created_at,
                          COALESCE(pallets.shipped_at, pallets.scrapped_at)
                  ) AS pallet_age,
                  fn_calc_age_days(
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at),
                          COALESCE(pallets.shipped_at, pallets.scrapped_at)
                  ) AS inspection_age,
                  fn_calc_age_days(
                          pallets.stock_created_at,
                          COALESCE(pallets.shipped_at, pallets.scrapped_at)
                  ) AS stock_age,
                  fn_calc_age_days(
                          pallets.first_cold_storage_at,
                          COALESCE(pallets.shipped_at, pallets.scrapped_at)
                  ) AS cold_age,
                  (
                      fn_calc_age_days(
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at),
                          COALESCE(pallets.shipped_at, pallets.scrapped_at))
                          -
                      fn_calc_age_days(
                          pallets.first_cold_storage_at,
                          COALESCE(pallets.shipped_at, pallets.scrapped_at))
                  ) AS ambient_age, -- (inspection_age - cold_age)
                  fn_calc_age_days(
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_reinspection_at),
                          COALESCE(pallets.shipped_at, pallets.scrapped_at)
                  ) AS reinspection_age,
                  fn_calc_age_days(
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at),
                          pallets.created_at
                  ) AS pack_to_inspect_age,
                  fn_calc_age_days(
                          pallets.first_cold_storage_at,
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at)
                  ) AS inspect_to_cold_age,
                  fn_calc_age_days(
                          COALESCE(pallets.first_cold_storage_at, COALESCE(pallets.shipped_at, pallets.scrapped_at)),
                          COALESCE(pallets.govt_reinspection_at, pallets.govt_first_inspection_at)
                  ) AS inspect_to_exit_warm_age
              FROM pallets
              WHERE
                      id  = in_id;
      END;$$;
      ALTER FUNCTION fn_pallet_ages(integer) OWNER TO postgres;
    SQL
  end

  down do
    run 'DROP FUNCTION public.fn_pallet_ages(integer);'
  end
end
