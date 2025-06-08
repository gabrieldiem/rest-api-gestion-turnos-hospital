Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }

module RoutesResourceTurnosDisponibles
  def self.registered(app)
    get_turnos_disponibles(app)
  end

  def self.get_turnos_disponibles(app)
    app.get '/medicos/:matricula/turnos-disponibles' do
      logger.debug("POST /medicos/#{params[:matricula]}/turnos-disponibles: #{@params}")

      medico = turnero.buscar_medico(params[:matricula])
      turnos_disponibles = turnero.obtener_turnos_disponibles(params[:matricula])

      status 200
      TurnosDisponiblesResponse.new(medico, turnos_disponibles, convertidor_de_tiempo).to_json
    rescue MedicoInexistenteException => e
      logger.error("Error al buscar médico: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    end
  end
end
