# frozen_string_literal: true

root_dir = File.expand_path('..', __dir__)
Dir["#{root_dir}/logistics/entities/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/interactors/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/jobs/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/repositories/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/services/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/task_permission_checks/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/ui_rules/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/validations/*.rb"].sort.each { |f| require f }
Dir["#{root_dir}/logistics/views/**/*.rb"].sort.each { |f| require f }

module LogisticsApp
end
