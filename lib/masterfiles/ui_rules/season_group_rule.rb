# frozen_string_literal: true

module UiRules
  class SeasonGroupRule < Base
    def generate_rules
      @repo = MasterfilesApp::CalendarRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if %i[show reopen].include? @mode
      form_name 'season_group'
    end

    def set_show_fields
      fields[:season_group_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:season_group_year] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        season_group_code: { required: true },
        description: {},
        season_group_year: { renderer: :integer }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_season_group(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(season_group_code: nil,
                                    description: nil,
                                    season_group_year: Time.now.year)
    end
  end
end
