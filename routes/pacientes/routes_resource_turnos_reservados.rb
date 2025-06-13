Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/pacientes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }

module RoutesResourceTurnosReservadosPacientes
  def self.registered(app)
    get_turnos_reservados(app)
  end

  def self.get_turnos_reservados(app)
    app.get '/pacientes/:dni/turnos-reservados' do
      logger.debug("GET /pacientes/#{params[:dni]}/turnos-reservados")

      turnos = turnero.obtener_turnos_reservados_del_paciente_por_dni(params[:dni])

      status 200
      TurnosReservadosPorPacienteResponse.new(turnos, convertidor_de_tiempo).to_json
    rescue PacienteInexistenteException => e
      logger.error("Error al buscar paciente: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    rescue SinTurnosException => e
      logger.error("Error El paciente #{params[:dni]} no tiene turnos: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    rescue ActiveModel::ValidationError => e
      logger.error("Error al reservar un turno: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.model.errors.first.message).to_json
    end
  end
end
