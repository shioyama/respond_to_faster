require "schema"

module RespondToFaster
  module Test
    class Database
      class << self
        def connect
          ::ActiveRecord::Base.establish_connection config[driver]
          ::ActiveRecord::Migration.verbose = false if in_memory?
        end

        def auto_migrate
          Schema.migrate :up if in_memory?
        end

        private

        def config
          @config ||= YAML::load(File.open(File.expand_path("../databases.yml", __FILE__)))
        end

        def driver
          (ENV["DB"] or "sqlite3").downcase
        end

        def in_memory?
          config[driver]["database"] == ":memory:"
        end
      end
    end
  end
end
