# frozen_string_literal: true

module MasterfilesApp
  StandardPackSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:standard_pack_code).filled(Types::StrippedString)
    required(:standard_pack_label).maybe(Types::StrippedString)
    required(:description).maybe(Types::StrippedString)
    required(:material_mass).filled(:decimal)
    required(:basic_pack_id).filled(:integer)
    required(:use_size_ref_for_edi).maybe(:bool)
  end
end
