# frozen_string_literal: true

module MasterfilesApp
  UomTypeSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:uom_type_code).filled(Types::StrippedString)
  end
end
