Sequel.migration do
  up do
    alter_table(:standard_pack_codes) do
      add_foreign_key :basic_pack_code_id, :basic_pack_codes
    end
  end

  down do
    alter_table(:standard_pack_codes) do
      drop_foreign_key :basic_pack_code_id
    end
  end
end
