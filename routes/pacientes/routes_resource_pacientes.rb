Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/pacientes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }

module RoutesResourcePacientes
  def self.registered(app)
    get_paciente_por_username(app)
    post_paciente(app)
  end

  def self.get_paciente_por_username(app)
    app.get '/pacientes' do
      logger.debug("GET /pacientes?username=#{params[:username]}")

      paciente = turnero.buscar_paciente_por_username(params[:username])
      status 200
      PacienteResponse.new(paciente).to_json
    rescue PacienteInexistenteException => e
      logger.error("Error al buscar paciente: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    rescue ActiveModel::ValidationError => e
      logger.error("Error al reservar un turno: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.model.errors.first.message).to_json
    end
  end

  def self.post_paciente(app)
    app.post '/pacientes' do
      logger.debug("POST /pacientes con params: #{@params}")
      paciente = turnero.crear_paciente(@params[:email].to_s, @params[:dni].to_s, @params[:username].to_s)
      status 201
      NuevoPacienteCreadoResponse.new(paciente).to_json
    rescue ActiveModel::ValidationError => e
      logger.error("Error al crear paciente: #{e.message}")
      status 400
      MensajeErrorResponse.new(e.model.errors.first.message).to_json
    end
  end
end
