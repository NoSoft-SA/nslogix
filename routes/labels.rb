# frozen_string_literal: true

Dir['./routes/labels/*.rb'].sort.each { |f| require f }

class Nslogix < Roda
  route('labels') do |r|
    store_current_functional_area('label designer')
    r.multi_route('labels')
  end
end
