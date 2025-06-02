require 'semantic_logger'
require 'sequel'

class Configuration
  def self.logger
    return SemanticLogger['REST_API'] if @logger_initialized

    SemanticLogger.default_level = (ENV['LOG_LEVEL'] || 'info').to_sym

    if SemanticLogger.appenders.empty?
      SemanticLogger.add_appender(
        io: $stdout,
        formatter: :color
      )

      log_url = ENV['LOG_URL']
      unless log_url.nil? || log_url.empty?
        SemanticLogger.add_appender(
          appender: :http,
          url: log_url
        )
      end
    end

    @logger_initialized = true
    SemanticLogger['REST_API']
  end

  def self.db
    database_url = case ENV['APP_MODE']
                   when 'test'
                     ENV['TEST_DB_URL'] || 'postgres://postgres:example@localhost:5433/postgres'
                   when 'development'
                     ENV['DEV_DB_URL'] || 'postgres://postgres:example@localhost:5434/postgres'
                   else
                     ENV['DATABASE_URL']
                   end
    Sequel::Model.raise_on_save_failure = true
    Sequel.connect(database_url)
  end
end
