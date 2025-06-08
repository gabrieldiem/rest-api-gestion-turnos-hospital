Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/medicos', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../../vistas/error', '*.rb')].each { |file| require file }

module RoutesResourceTurnosReservados
  def self.registered(app)
    get_turnos_reservados(app)
    post_turnos_reservados(app)
  end

  def self.get_turnos_reservados(app)
    app.get '/medicos/:matricula/turnos-reservados' do
      logger.debug("GET /medicos/#{params[:matricula]}/turnos-reservados")

      turnos = turnero.obtener_turnos_reservados_por_medico(params[:matricula])

      status 200
      TurnosReservadosResponse.new(turnos, convertidor_de_tiempo).to_json
    rescue MedicoInexistenteException => e
      logger.error("Error al buscar médico: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    rescue SinTurnosException => e
      logger.error("Error El médico #{params[:matricula]} no tiene turnos: #{e.message}")
      status 404
      MensajeErrorResponse.new(e.message).to_json
    end
  end

  def self.post_turnos_reservados(app)
    app.post '/medicos/:matricula/turnos-reservados' do
      logger.debug("POST /medicos/#{@params['matricula']}/turnos-reservados con params: #{@params}")
      turno = turnero.asignar_turno(@params['matricula'],
                                    @params[:turno][:fecha].to_s,
                                    @params[:turno][:hora].to_s,
                                    @params[:dni].to_s)
      status 201

      NuevoTurnoReservadoResponse.new(turno, convertidor_de_tiempo).to_json
    rescue StandardError => e
      logger.error("Error al reservar con medico: #{e.message}")
      status 400
      MensajeErrorResponse.new(e.message).to_json
    end
  end
end
