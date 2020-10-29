require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    create_table(:users, ignore_index_errors: true) do
      primary_key :id
      String :login_name, size: 255, null: false
      String :user_name, size: 255
      String :password_hash, size: 255, null: false
      String :email, size: 255
      Jsonb :permission_tree
      Jsonb :profile
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:login_name], name: :users_unique_login_name, unique: true
    end

    alter_table(:users) do
      set_column_type :login_name, :citext
    end

    pgt_created_at(:users,
                   :created_at,
                   function_name: :users_set_created_at,
                   trigger_name: :set_created_at)

    pgt_updated_at(:users,
                   :updated_at,
                   function_name: :users_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:users, :set_created_at)
    drop_function(:users_set_created_at)
    drop_trigger(:users, :set_updated_at)
    drop_function(:users_set_updated_at)
    drop_table :users
  end
end
