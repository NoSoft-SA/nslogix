require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:edi_out_rules, ignore_index_errors: true) do
      primary_key :id
      String :flow_type, null: false
      foreign_key :depot_id, :depots, type: :integer
      foreign_key :party_role_id, :party_roles, type: :integer
      String :hub_address, null: false
      column :directory_keys, 'text[]', null: false
      TrueClass :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:edi_out_rules,
                   :created_at,
                   function_name: :pgt_edi_out_rules_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:edi_out_rules,
                   :updated_at,
                   function_name: :pgt_edi_out_rules_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('edi_out_rules', true, true, '{updated_at}'::text[]);"

    create_table(:edi_out_transactions, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_role_id, :party_roles, type: :integer
      foreign_key :edi_out_rule_id, :edi_out_rules, type: :integer
      String :flow_type, null: false
      String :org_code, null: false
      String :hub_address, null: false
      String :user_name, null: false
      TrueClass :complete, default: false
      String :edi_out_filename
      String :backtrace
      Integer :record_id
      String :error_message
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:edi_out_transactions,
                   :created_at,
                   function_name: :pgt_edi_out_transactions_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:edi_out_transactions,
                   :updated_at,
                   function_name: :pgt_edi_out_transactions_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('edi_out_transactions', true, true, '{updated_at}'::text[]);"

    create_table(:edi_in_transactions, ignore_index_errors: true) do
      primary_key :id
      String :file_name, null: false
      String :flow_type
      String :notes
      String :match_data, text: true
      String :backtrace
      TrueClass :complete, default: false
      TrueClass :schema_valid, default: false
      TrueClass :newer_edi_received, default: false
      TrueClass :has_missing_master_files, default: false
      TrueClass :valid, default: false
      TrueClass :has_discrepancies, default: false
      TrueClass :reprocessed, default: false
      String :error_message
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:file_name, :complete], name: :edi_in_tran_file_complete
      index :created_at, name: :edi_in_tran_created
    end
    pgt_created_at(:edi_in_transactions,
                   :created_at,
                   function_name: :pgt_edi_in_transactions_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:edi_in_transactions,
                   :updated_at,
                   function_name: :pgt_edi_in_transactions_set_updated_at,
                   trigger_name: :set_updated_at)

    # Log changes to this table. Exclude changes to the updated_at column.
    run "SELECT audit.audit_table('edi_in_transactions', true, true, '{updated_at}'::text[]);"
  end

  down do
    # Drop logging for this table.
    drop_trigger(:edi_in_transactions, :audit_trigger_row)
    drop_trigger(:edi_in_transactions, :audit_trigger_stm)

    drop_trigger(:edi_in_transactions, :set_created_at)
    drop_function(:pgt_edi_in_transactions_set_created_at)
    drop_trigger(:edi_in_transactions, :set_updated_at)
    drop_function(:pgt_edi_in_transactions_set_updated_at)
    drop_table(:edi_in_transactions)

    # Drop logging for this table.
    drop_trigger(:edi_out_transactions, :audit_trigger_row)
    drop_trigger(:edi_out_transactions, :audit_trigger_stm)

    drop_trigger(:edi_out_transactions, :set_created_at)
    drop_function(:pgt_edi_out_transactions_set_created_at)
    drop_trigger(:edi_out_transactions, :set_updated_at)
    drop_function(:pgt_edi_out_transactions_set_updated_at)
    drop_table(:edi_out_transactions)

    # Drop logging for this table.
    drop_trigger(:edi_out_rules, :audit_trigger_row)
    drop_trigger(:edi_out_rules, :audit_trigger_stm)

    drop_trigger(:edi_out_rules, :set_created_at)
    drop_function(:pgt_edi_out_rules_set_created_at)
    drop_trigger(:edi_out_rules, :set_updated_at)
    drop_function(:pgt_edi_out_rules_set_updated_at)
    drop_table(:edi_out_rules)
  end
end
