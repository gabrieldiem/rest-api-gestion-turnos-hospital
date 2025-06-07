Dir[File.join(__dir__, '../dominio', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../dominio/exceptions', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../persistencia', '*.rb')].each { |file| require file }

module RoutesMedicos
  def self.registered(app)
    app.get '/medicos' do
      logger.debug('GET /medicos')

      medicos = turnero.obtener_medicos

      status 200
      {
        cantidad_total: medicos.size,
        medicos: medicos.map do |medico|
          {
            id: medico.id,
            nombre: medico.nombre,
            apellido: medico.apellido,
            matricula: medico.matricula,
            especialidad: medico.especialidad.nombre,
            created_on: medico.created_on
          }
        end
      }.to_json
    end

    app.post '/medicos' do
      logger.debug("POST /medicos con params: #{@params}")
      medico = turnero.crear_medico(@params[:nombre].to_s,
                                    @params[:apellido].to_s,
                                    @params[:matricula].to_s,
                                    @params[:especialidad].to_s)
      status 201
      {
        id: medico.id,
        nombre: medico.nombre,
        apellido: medico.apellido,
        matricula: medico.matricula,
        especialidad: medico.especialidad.codigo,
        created_on: medico.created_on
      }.to_json
    end

    app.get '/medicos/:matricula/turnos-disponibles' do
      logger.debug("POST /medicos/#{params[:matricula]}/turnos-disponibles: #{@params}")

      medico = turnero.buscar_medico(params[:matricula])
      turnos_disponibles = turnero.obtener_turnos_disponibles(params[:matricula])

      turnos_parseados = turnos_disponibles.map do |turno|
        {
          fecha: turno.fecha.to_s,
          hora: "#{turno.hora.hora}:#{turno.hora.minutos.to_s.rjust(2, '0')}"
        }
      end

      status 200
      {
        medico: {
          nombre: medico.nombre,
          apellido: medico.apellido,
          matricula: medico.matricula,
          especialidad: medico.especialidad.codigo
        },
        turnos: turnos_parseados
      }.to_json
    rescue MedicoInexistenteException => e
      logger.error("Error al buscar médico: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    end

    app.post '/medicos/:matricula/turnos-reservados' do
      logger.debug("POST /medicos/#{@params['matricula']}/turnos-reservados con params: #{@params}")
      turno = turnero.asignar_turno(@params['matricula'], @params[:turno][:fecha].to_s, @params[:turno][:hora].to_s, @params[:dni].to_s)
      status 201
      {
        id: turno.id,
        matricula: turno.medico.matricula,
        dni: turno.paciente.dni,
        turno: {
          fecha: turno.horario.fecha.to_s,
          hora: "#{turno.horario.hora.hora}:#{turno.horario.hora.minutos.to_s.rjust(2, '0')}"
        },
        created_at: turno.created_on.to_s
      }.to_json
    rescue StandardError => e
      logger.error("Error al reservar con medico: #{e.message}")
      status 400
      { mensaje_error: e.message }.to_json
    end

    app.get '/medicos/:matricula/turnos-reservados' do
      logger.debug("GET /medicos/#{params[:matricula]}/turnos-reservados")

      turnos = turnero.obtener_turnos_reservados_por_medico(params[:matricula])

      status 200
      {
        cantidad_turnos: turnos.size,
        turnos: turnos.map do |turno|
          {
            fecha: turno[:fecha].to_s,
            hora: turno[:hora].to_s,
            paciente: {
              dni: turno[:paciente][:dni].to_s
            }
          }
        end
      }.to_json
    rescue MedicoInexistenteException => e
      logger.error("Error al buscar médico: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    rescue SinTurnosException => e
      logger.error("Error El médico #{params[:matricula]} no tiene turnos: #{e.message}")
      status 404
      { mensaje_error: e.message }.to_json
    end
  end
end
