# frozen_string_literal: true

module MasterfilesApp
  CommodityGroupSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:commodity_group_code).filled(Types::StrippedString)
    required(:description).filled(Types::StrippedString)
    # required(:active).filled(:bool)
  end
end
