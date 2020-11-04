Sequel.migration do
  up do
    create_table(:programs_users, ignore_index_errors: true) do
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :program_id, :programs, null: false
      foreign_key :security_group_id, :security_groups, null: false
      
      index [:program_id], name: :fki_programs_users_program
      index [:security_group_id], name: :fki_programs_users_security_group
      index [:user_id], name: :fki_programs_users_user
      index [:user_id, :program_id, :security_group_id], name: :programs_users_unique, unique: true
    end
  end

  down do
    drop_table(:programs_users)
  end
end
