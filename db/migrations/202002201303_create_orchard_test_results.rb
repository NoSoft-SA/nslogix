require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers

    create_table(:orchard_test_types, ignore_index_errors: true) do
      primary_key :id
      String :test_type_code, null: false
      String :description

      TrueClass :applies_to_all_markets, default: true
      TrueClass :applies_to_all_cultivars, default: true
      TrueClass :applies_to_orchard, default: true
      TrueClass :allow_result_capturing, default: true
      TrueClass :pallet_level_result, default: true

      String :api_name
      String :result_type, null: false
      String :api_attribute
      String :api_pass_result
      String :api_default_result

      column :applicable_tm_group_ids, 'integer[]'
      column :applicable_cultivar_ids, 'integer[]'
      column :applicable_commodity_group_ids, 'integer[]'

      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:test_type_code], name: :orchard_test_types_unique_code, unique: true
      index [:api_attribute], name: :orchard_test_types_api_attribute_idx, unique: true
    end
    pgt_created_at(:orchard_test_types,
                   :created_at,
                   function_name: :pgt_orchard_test_types_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:orchard_test_types,
                   :updated_at,
                   function_name: :pgt_orchard_test_types_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('orchard_test_types', true, true, '{updated_at}'::text[]);"


    create_table(:orchard_test_results, ignore_index_errors: true) do
      primary_key :id
      foreign_key :orchard_test_type_id, :orchard_test_types, type: :integer, null: false
      foreign_key :puc_id, :pucs, type: :integer, null: false
      foreign_key :orchard_id, :orchards, type: :integer, null: false
      foreign_key :cultivar_id, :cultivars, type: :integer, null: false
      String :description
      TrueClass :passed, default: false
      String :api_result
      TrueClass :classification, default: false
      TrueClass :freeze_result, default: false
      Jsonb :api_response
      DateTime :applicable_from
      DateTime :applicable_to

      TrueClass :active, default: true
      DateTime :created_at
      DateTime :updated_at

      index [:orchard_test_type_id], name: :orchard_test_type_id
      index [:orchard_test_type_id, :puc_id, :orchard_id, :cultivar_id], name: :orchard_test_type_orchard_unique_code, unique: true
    end
    pgt_created_at(:orchard_test_results,
                   :created_at,
                   function_name: :pgt_orchard_test_results_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:orchard_test_results,
                   :updated_at,
                   function_name: :pgt_orchard_test_results_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('orchard_test_results', true, true, '{updated_at}'::text[]);"

    create_table(:orchard_test_logs, ignore_index_errors: true) do
      primary_key :id
      Integer :orchard_test_result_id
      Integer :orchard_test_type_id
      Integer :puc_id
      Integer :orchard_id
      Integer :cultivar_id

      String :description

      TrueClass :passed, default: false
      String :api_result

      TrueClass :classification, default: false
      TrueClass :freeze_result, default: false
      Jsonb :api_response

      DateTime :applicable_from
      DateTime :applicable_to

      TrueClass :active, default: true
      DateTime :created_at
      DateTime :updated_at
      DateTime :logged_at, null: false

      index [:orchard_test_type_id], name: :orchard_test_type_id
    end
    pgt_created_at(:orchard_test_logs,
                   :logged_at,
                   function_name: :pgt_orchard_test_logs_set_logged_at,
                   trigger_name: :set_created_at)

    create_table(:orchard_test_api_attributes, ignore_index_errors: true) do
      primary_key :id
      String :api_name, null: false
      String :api_attribute, null: false
      String :description
      column :api_results, 'text[]'

      index [:api_attribute], name: :orchard_test_api_attribute_unique_name, unique: true
    end

    add_column :pallet_sequences, :failed_otmc_results, 'integer[]'
    add_column :pallet_sequences, :phyto_data, String

    run <<~SQL
      CREATE OR REPLACE FUNCTION public.fn_log_orchard_test_result()
        RETURNS TRIGGER
        AS
        $$
        BEGIN
          INSERT INTO orchard_test_logs
           (orchard_test_result_id,
            orchard_test_type_id,
            puc_id,
            orchard_id,
            cultivar_id,
            description,
            passed,
            classification_only,
            freeze_result,
            api_result,
            classification,
            applicable_from,
            applicable_to,
            active,
            created_at,
            updated_at)
          VALUES 
           (NEW.id,
            NEW.orchard_test_type_id,
            NEW.puc_id,
            NEW.orchard_id,
            NEW.cultivar_id,
            NEW.description,
            NEW.passed,
            NEW.classification_only,
            NEW.freeze_result,
            NEW.api_result,
            NEW.classification,
            NEW.applicable_from,
            NEW.applicable_to,
            NEW.active,
            NEW.created_at,
            NEW.updated_at);
          RETURN NEW;
          END;
         $$
        LANGUAGE plpgsql;

      CREATE TRIGGER log_orchard_test_result
      AFTER UPDATE
      ON public.orchard_test_results
      FOR EACH ROW
      EXECUTE PROCEDURE public.fn_log_orchard_test_result();
    SQL
  end

  down do
    run <<~SQL
      DROP TRIGGER log_orchard_test_result ON public.orchard_test_results;
      DROP FUNCTION public.fn_log_orchard_test_result();
    SQL

    drop_column :pallet_sequences, :phyto_data
    drop_column :pallet_sequences, :failed_otmc_results
    drop_column :orchards, :otmc_results

    drop_table(:orchard_test_api_attributes)

    drop_trigger(:orchard_test_logs, :set_created_at)
    drop_function(:pgt_orchard_test_logs_set_logged_at)
    drop_table(:orchard_test_logs)

    # Drop logging for this table.
    drop_trigger(:orchard_test_results, :audit_trigger_row)
    drop_trigger(:orchard_test_results, :audit_trigger_stm)

    drop_trigger(:orchard_test_results, :set_created_at)
    drop_function(:pgt_orchard_test_results_set_created_at)
    drop_trigger(:orchard_test_results, :set_updated_at)
    drop_function(:pgt_orchard_test_results_set_updated_at)
    drop_table(:orchard_test_results)

    # Drop logging for this table.
    drop_trigger(:orchard_test_types, :audit_trigger_row)
    drop_trigger(:orchard_test_types, :audit_trigger_stm)

    drop_trigger(:orchard_test_types, :set_created_at)
    drop_function(:pgt_orchard_test_types_set_created_at)
    drop_trigger(:orchard_test_types, :set_updated_at)
    drop_function(:pgt_orchard_test_types_set_updated_at)
    drop_table(:orchard_test_types)
  end
end
