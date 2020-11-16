# frozen_string_literal: true

Dir['./routes/logistics/*.rb'].sort.each { |f| require f }

class Nslogix < Roda
  route('logistics') do |r|
    store_current_functional_area('logistics')
    r.multi_route('logistics')
  end
end
