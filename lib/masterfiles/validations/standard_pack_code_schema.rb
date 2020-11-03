# frozen_string_literal: true

module MasterfilesApp
  class StandardPackCodeContract < Dry::Validation::Contract
    params do
      optional(:id).filled(:integer)
      required(:standard_pack_code).filled(Types::StrippedString)
      required(:material_mass).filled(:decimal)
      required(:description).maybe(Types::StrippedString)
      required(:std_pack_label_code).maybe(Types::StrippedString)
      required(:basic_pack_code_id).filled(:integer)
      required(:use_size_ref_for_edi).maybe(:bool)
      required(:bin).filled(:bool)
    end
  end
end
