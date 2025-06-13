Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../vistas/error', '*.rb')].each { |file| require file }

module RoutesSystemControl
  TEST_STAGE = 'test'.freeze
  PROD_STAGE = 'prod'.freeze

  def self.registered(app)
    app.get '/version' do
      logger.debug('GET /version')
      json({ version: Version.current })
    end

    app.post '/reset' do
      habilitado = stage == TEST_STAGE
      turnero.borrar_todos_los_datos(habilitado)
      status 200
    rescue AccionProhibidaException => e
      status 403
      MensajeErrorResponse.new(e.message).to_json
    end

    app.get '/health-check' do
      logger.debug('GET health-check')
      repo_especialidades = RepositorioEspecialidades.new(logger)
      repo_especialidades.find_by_codigo('card')

      status 200
      return
    rescue Sequel::DatabaseConnectionError
      status 503
      MensajeErrorResponse.new('Servicio no disponible').to_json
    end
  end
end
