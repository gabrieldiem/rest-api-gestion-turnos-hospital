Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }

module RoutesSystemControl
  def self.registered(app)
    app.get '/version' do
      logger.debug('GET /version')
      json({ version: Version.current })
    end

    app.post '/reset' do
      status 200
    end

    app.get '/health-check' do
      logger.debug('GET health-check')
      repo_especialidades = RepositorioEspecialidades.new(logger)
      repo_especialidades.find_by_codigo('card')

      status 200
      return
    rescue Sequel::DatabaseConnectionError
      status 503
      {
        "mensaje_error": 'Servicio no disponible'
      }.to_json
    end
  end
end
