Dir[File.join(__dir__, 'dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../vistas/turnos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../vistas/error', '*.rb')].each { |file| require file }

module RoutesTurnos
  def self.registered(app)
    get_turnos_por_id(app)
    put_turnos(app)
    put_turnos_cancelar(app)
  end

  def self.get_turnos_por_id(app)
    app.get '/turnos/:id' do
      logger.debug("GET /turnos/#{params['id']}")
      turno = turnero.buscar_turno(params['id'].to_i)
      status 200
      ObtenerTurnoResponse.new(turno, convertidor_de_tiempo).to_json
    end
  end

  def self.put_turnos(app)
    app.put '/turnos/:id' do
      logger.debug("PUT /turnos con params: #{params}")
      turno = turnero.cambiar_asistencia_turno(params['id'].to_i, params[:dni_paciente].to_s, params[:asistio])
      status 200
      ActualizacionDeTurnoResponse.new(turno, convertidor_de_tiempo).to_json
    rescue PacienteInexistenteException => e
      logger.error("Error al cambiar asistencia del turno: #{e.message}")
      status 404
      MensajeErrorResponse.new('Paciente inexistente').to_json
    rescue TurnoInexistenteException => e
      logger.error("Error al cambiar asistencia del turno: #{e.message}")
      status 404
      MensajeErrorResponse.new('Turno inexistente').to_json
    rescue PacienteInvalidoException => e
      logger.error("Error al cambiar asistencia del turno: #{e.message}")
      status 400
      MensajeErrorResponse.new('El turno no pertenece a ese paciente').to_json
    rescue ReputacionInvalidaException => e
      logger.error("Error al cambiar asistencia del turno: #{e.message}")
      status 400
      MensajeErrorResponse.new('Su reputación no es suficiente para cambiar la asistencia de este turno').to_json
    end
  end

  def self.put_turnos_cancelar(app)
    app.put '/turnos/cancelar/:id' do
      logger.debug("PUT /turnos/cancelar/#{params['id']} con params: #{params}")
      turnero.cancelar_turno(params['id'].to_i)
      status 200
    rescue TurnoInexistenteException => e
      logger.error("Error al cancelar el turno: #{e.message}")
      status 404
      MensajeErrorResponse.new('Turno inexistente').to_json
    rescue TurnoInvalidoException => e
      logger.error("Error al cancelar el turno: #{e.message}")
      status 400
      MensajeErrorResponse.new('No se puede cancelar un turno que ya ha sido actualizado').to_json
    end
  end
end
