# frozen_string_literal: true

module MasterfilesApp
  InventoryCodeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:inventory_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
  end
end
