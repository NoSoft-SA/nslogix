# frozen_string_literal: true

module MasterfilesApp
  class Mark < Dry::Struct
    attribute :id, Types::Integer
    attribute :mark_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
