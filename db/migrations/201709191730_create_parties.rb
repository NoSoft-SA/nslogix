require 'sequel_postgresql_triggers'
Sequel.migration do
  up do
    extension :pg_triggers
    extension :pg_array

    # --- PARTY
    create_table(:parties, ignore_index_errors: true) do
      primary_key :id
      String :party_type, size: 1, default: 'O', null: false
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
    pgt_created_at(:parties,
                   :created_at,
                   function_name: :pgt_parties_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:parties,
                   :updated_at,
                   function_name: :pgt_parties_set_updated_at,
                   trigger_name: :set_updated_at)

    # --- ROLE
    create_table(:roles, ignore_index_errors: true) do
      primary_key :id
      String :name, size: 255
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:name], name: :roles_name_uniq, unique: true
    end
    pgt_created_at(:roles,
                   :created_at,
                   function_name: :pgt_roles_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:roles,
                   :updated_at,
                   function_name: :pgt_roles_set_updated_at,
                   trigger_name: :set_updated_at)

    # --- ORG
    create_table(:organizations, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_id, :parties, type: :integer, null: false
      foreign_key :parent_id, :organizations, type: :integer
      String :short_description, size: 255, null: false
      String :medium_description, size: 255, null: false
      String :long_description, size: 255, null: false
      String :vat_number, size: 255
      String :company_reg_no
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:short_description], name: :organizations_unique_short_desc, unique: true
      index [:party_id], name: :fki_organizations_party_id, unique: true
    end
    pgt_created_at(:organizations,
                   :created_at,
                   function_name: :pgt_organizations_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:organizations,
                   :updated_at,
                   function_name: :pgt_organizations_set_updated_at,
                   trigger_name: :set_updated_at)

    # --- PERSON
    create_table(:people, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_id, :parties, type: :integer, null: false
      String :surname, size: 255, null: false
      String :first_name, size: 255, null: false
      String :title, size: 255, null: false
      String :vat_number, size: 255
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:surname, :first_name], name: :people_unique_name, unique: true
      index [:party_id], name: :fki_organizations_party_id, unique: true
    end
    pgt_created_at(:people,
                   :created_at,
                   function_name: :pgt_people_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:people,
                   :updated_at,
                   function_name: :pgt_people_set_updated_at,
                   trigger_name: :set_updated_at)

    # --- PARTY ROLE
    create_table(:party_roles, ignore_index_errors: true) do
      primary_key :id
      foreign_key :party_id, :parties, type: :integer, null: false
      foreign_key :role_id, :roles, type: :integer, null: false
      foreign_key :organization_id, :organizations, type: :integer
      foreign_key :person_id, :people, type: :integer
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:party_id], name: :fki_party_roles_party_id
      index [:organization_id], name: :fki_party_roles_organization_id
      index [:person_id], name: :fki_party_roles_person_id
      index [:party_id, :role_id], name: :party_role_uniq, unique: true
    end
    pgt_created_at(:party_roles,
                   :created_at,
                   function_name: :pgt_party_roles_set_created_at,
                   trigger_name: :set_created_at)
    pgt_updated_at(:party_roles,
                   :updated_at,
                   function_name: :pgt_party_roles_set_updated_at,
                   trigger_name: :set_updated_at)
  end

  down do
    drop_trigger(:party_roles, :set_created_at)
    drop_function(:pgt_party_roles_set_created_at)
    drop_trigger(:party_roles, :set_updated_at)
    drop_function(:pgt_party_roles_set_updated_at)
    drop_table(:party_roles)

    drop_trigger(:people, :set_created_at)
    drop_function(:pgt_people_set_created_at)
    drop_trigger(:people, :set_updated_at)
    drop_function(:pgt_people_set_updated_at)
    drop_table(:people)

    drop_trigger(:organizations, :set_created_at)
    drop_function(:pgt_organizations_set_created_at)
    drop_trigger(:organizations, :set_updated_at)
    drop_function(:pgt_organizations_set_updated_at)
    drop_table(:organizations)

    drop_trigger(:roles, :set_created_at)
    drop_function(:pgt_roles_set_created_at)
    drop_trigger(:roles, :set_updated_at)
    drop_function(:pgt_roles_set_updated_at)
    drop_table(:roles)

    drop_trigger(:parties, :set_created_at)
    drop_function(:pgt_parties_set_created_at)
    drop_trigger(:parties, :set_updated_at)
    drop_function(:pgt_parties_set_updated_at)
    drop_table(:parties)
  end
end
