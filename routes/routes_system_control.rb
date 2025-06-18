Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../vistas/error', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', '*.rb')].each { |file| require file }

module RoutesSystemControl
  TEST_STAGE = 'test'.freeze
  PROD_STAGE = 'prod'.freeze

  def self.registered(app)
    get_version(app)
    post_reset(app)
    post_definir_fecha(app)
    get_health_check(app)
  end

  def self.get_version(app)
    app.get '/version' do
      logger.debug('GET /version')
      json({ version: Version.current })
    end
  end

  def self.post_reset(app)
    app.post '/reset' do
      habilitado = stage == TEST_STAGE
      turnero.borrar_todos_los_datos(habilitado)
      status 200
    rescue AccionProhibidaException => e
      status 403
      MensajeErrorResponse.new(e.message).to_json
    end
  end

  def self.post_definir_fecha(app)
    app.post '/definir_fecha' do
      habilitado = stage == TEST_STAGE
      fecha = Date.parse(params[:fecha])
      hora = DateTime.parse(params[:hora])

      proveedor_de_fecha = ProveedorDeFechaFijo.new(fecha)
      proveedor_de_hora = ProveedorDeHoraFijo.new(hora)
      turnero.actualizar_fecha_actual(habilitado, proveedor_de_fecha, proveedor_de_hora)
      status 200
    rescue Date::Error => e
      status 400
      MensajeErrorResponse.new('Fecha o hora es inválida').to_json
    rescue AccionProhibidaException => e
      status 403
      MensajeErrorResponse.new(e.message).to_json
    end
  end

  def self.post_definir_fecha(app)
    app.delete '/definir_fecha' do
      habilitado = stage == TEST_STAGE
      turnero.actualizar_fecha_actual(habilitado, ProveedorDeFecha.new, ProveedorDeHora.new)
      status 200
    rescue Date::Error => e
      status 400
      MensajeErrorResponse.new("Fecha o hora es inválida").to_json
    rescue AccionProhibidaException => e
      status 403
      MensajeErrorResponse.new(e.message).to_json
    end
  end

  def self.get_health_check(app)
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
