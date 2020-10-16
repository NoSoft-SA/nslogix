# frozen_string_literal: true

module MasterfilesApp
  class SeasonGroup < Dry::Struct
    attribute :id, Types::Integer
    attribute :season_group_code, Types::String
    attribute :description, Types::String
    attribute :season_group_year, Types::Integer
    attribute? :active, Types::Bool
  end
end
