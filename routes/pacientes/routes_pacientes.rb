Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }

module RoutesPacientes
  def self.registered(app)
    app.get '/pacientes' do
      logger.debug("GET /pacientes/#{params[:username]}")

      paciente = turnero.buscar_paciente_por_username(params[:username])
      status 200
      {
        username: paciente.username,
        dni: paciente.dni,
        email: paciente.email
      }.to_json

    rescue PacienteInexistenteException => e
      logger.error("Error al buscar paciente: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    end

    app.post '/pacientes' do
      logger.debug("POST /pacientes con params: #{@params}")
      paciente = turnero.crear_paciente(@params[:email].to_s, @params[:dni].to_s, @params[:username].to_s)
      status 201
      {
        id: paciente.id,
        username: paciente.username,
        dni: paciente.dni,
        email: paciente.email,
        created_on: paciente.created_on
      }.to_json
    rescue ActiveModel::ValidationError => e
      logger.error("Error al crear paciente: #{e.message}")
      status 400
      { mensaje_error: e.model.errors.first.message }.to_json
    end

    app.get '/pacientes/:dni/turnos-reservados' do
      logger.debug("GET /pacientes/#{params[:dni]}/turnos-reservados")

      turnos = turnero.obtener_turnos_reservados_del_paciente_por_dni(params[:dni])

      status 200
      { turnos:, cantidad_de_turnos: turnos.size }.to_json
    rescue PacienteInexistenteException => e
      logger.error("Error al buscar paciente: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    rescue SinTurnosException => e
      logger.error("Error El paciente #{params[:dni]} no tiene turnos: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    end
  end
end
