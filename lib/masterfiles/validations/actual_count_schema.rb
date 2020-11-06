# frozen_string_literal: true

module MasterfilesApp
  ActualCountSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:standard_count_id).filled(:integer)
    required(:basic_pack_id).filled(:integer)
    required(:actual_count_value).filled(:integer)
    required(:standard_pack_ids).maybe(:array).each(:integer)
    required(:size_reference_ids).maybe(:array).each(:integer)
  end
end
