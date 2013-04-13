require 'activerecord-futures'

config = {
  adapter: "future_enabled_mysql2",
  database: "test",
  username: "root",
  password: "root",
  database: "activerecord_futures_test",
  host: "localhost"
}

ActiveRecord::Base.establish_connection(config)
require 'db/schema'
Dir['./spec/models/**/*.rb'].each { |f| require f }

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

require 'rspec-spies'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.after do
    ActiveRecord::Futures::Future.clear
  end
end
