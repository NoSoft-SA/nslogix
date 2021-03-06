Sequel.migration do
  up do
    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_party_name(in_id integer)
        RETURNS text AS
      $BODY$
      SELECT DISTINCT COALESCE(o.medium_description, p.first_name || ' ' || p.surname) AS party_name
        FROM party_roles pr
        LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
        LEFT OUTER JOIN people p ON p.id = pr.person_id
        JOIN parties y ON y.id = pr.party_id
        WHERE y.id = in_id
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_party_name(integer)
        OWNER TO postgres;
    SQL

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_party_role_name(in_id integer)
        RETURNS text AS
      $BODY$
        SELECT COALESCE(o.medium_description, p.first_name || ' ' || p.surname) AS party_name
        FROM party_roles pr
        LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
        LEFT OUTER JOIN people p ON p.id = pr.person_id
        WHERE pr.id = in_id
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_party_role_name(integer)
        OWNER TO postgres;
    SQL

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_party_role_name_with_role(in_id integer)
        RETURNS text AS
      $BODY$
        SELECT COALESCE(o.medium_description, p.first_name || ' ' || p.surname) || ' - ' || r.name AS party_name
        FROM party_roles pr
        LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
        LEFT OUTER JOIN people p ON p.id = pr.person_id
        JOIN roles r ON r.id = pr.role_id
        WHERE pr.id = in_id
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_party_role_name_with_role(integer)
        OWNER TO postgres;
    SQL

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_party_role_org_code(in_id integer)
        RETURNS text AS
      $BODY$
        SELECT COALESCE(o.short_description, p.first_name || ' ' || p.surname) AS party_name
        FROM party_roles pr
        LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
        LEFT OUTER JOIN people p ON p.id = pr.person_id
        WHERE pr.id = in_id
      $BODY$
        LANGUAGE sql VOLATILE
        COST 100;
      ALTER FUNCTION public.fn_party_role_org_code(integer)
        OWNER TO postgres;
    SQL
  end

  down do
    run 'DROP FUNCTION public.fn_party_role_org_code(integer);'
    run 'DROP FUNCTION public.fn_party_role_name_with_role(integer);'
    run 'DROP FUNCTION public.fn_party_role_name(integer);'
    run 'DROP FUNCTION public.fn_party_name(integer);'
  end
end
