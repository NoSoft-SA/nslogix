# frozen_string_literal: true

module EdiApp
  class PsInRepo < EdiInRepo
    def time_from_date_val(date)
      return nil if date.nil?

      Time.new(date[0, 4], date[4, 2], date[6, 3])
    end

    def time_from_date_and_time(date, time)
      return nil if date.nil? || time.nil?

      Time.new(date[0, 4], date[4, 2], date[6, 3], *time.split(':'))
    end

    def get_masterfile_variant(table_name, args)
      id = repo.get_variant_id(table_name, args)
      return id unless id.nil?

      missing_masterfiles << "#{table_name}: #{args} for #{pallet_number}"
      nil
    end

    def get_masterfile_id(table_name, args)
      get_masterfile_value(table_name, :id, args)
    end

    def get_masterfile_value(table_name, column, args)
      value = repo.get_value(table_name, column, args)
      return value unless value.nil?

      missing_masterfiles << "#{table_name}.#{column} #{args} for #{pallet_number}"
      nil
    end
  end
end
