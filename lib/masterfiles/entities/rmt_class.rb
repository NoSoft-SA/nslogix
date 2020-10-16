# frozen_string_literal: true

module MasterfilesApp
  class RmtClass < Dry::Struct
    attribute :id, Types::Integer
    attribute :rmt_class_code, Types::String
    attribute :description, Types::String
    attribute? :active, Types::Bool
  end
end
