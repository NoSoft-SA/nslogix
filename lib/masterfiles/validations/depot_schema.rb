# frozen_string_literal: true

module MasterfilesApp
  DepotSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:city_id).maybe(:integer)
    required(:depot_code).filled(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
    required(:receive_edi).maybe(:bool)
  end
end
