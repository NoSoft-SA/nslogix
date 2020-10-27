Sequel.migration do
  up do
    alter_table(:pallets) do
      add_foreign_key :edi_in_transaction_id, :edi_in_transactions, type: :integer
    end
  end

  down do
    alter_table(:pallets) do
      drop_foreign_key :edi_in_transaction_id
    end
  end
end
