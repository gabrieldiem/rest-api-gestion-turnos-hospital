Before do
  ENV['API_FERIADOS_URL'] = 'http://feriados_url.com'
  @api_feriado_url = ENV['API_FERIADOS_URL']
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger

  RepositorioTurnos.new(@logger).delete_all
  RepositorioMedicos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que esta registrado el username {string} y DNI {string}') do |username, dni|
  @username_registrado = username
  @dni_registrado = dni
  body = { email: 'juan.perez@example.com', dni: @dni_registrado, username: }
  @response = Faraday.post('/pacientes', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('que existe un médico con nombre {string}, apellido {string}, matrícula {string} y especialidad {string} con duración de {string} minutos') do |nombre_medico, apellido_medico, matricula_medico, nombre_especialidad, duracion_turno|
  codigo_especialidad = nombre_especialidad.downcase[0..3]
  body = {
    nombre: nombre_especialidad,
    duracion: duracion_turno,
    recurrencia_maxima: 5,
    codigo: codigo_especialidad
  }
  @duracion_turno = duracion_turno.to_i
  @response = Faraday.post('/especialidades', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)

  body = {
    nombre: nombre_medico,
    apellido: apellido_medico,
    matricula: matricula_medico,
    especialidad: codigo_especialidad
  }
  @response = Faraday.post('/medicos', body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Dado('no hay turnos asignados para el médico con matrícula {string}') do |matricula|
  # Nada que hacer
end

Cuando('solicito los turnos disponibles con {string}') do |matricula|
  @matricula = matricula
  @response = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
  @parsed_response = JSON.parse(@response.body)
end

Entonces('recibo los próximos {int} turnos disponibles') do |cantidad_de_turnos_esperada|
  @turnos_disponibles = @parsed_response['turnos']

  expect(@turnos_disponibles).not_to be nil
  expect(@turnos_disponibles.size).to eq(cantidad_de_turnos_esperada)
end

Entonces('son del {string} a las {string} en adelante') do |fecha, hora|
  fecha = Date.parse(fecha).to_s

  primer_turno = @turnos_disponibles.first
  expect(primer_turno['fecha']).to eq(fecha)
  expect(primer_turno['hora']).to eq(hora)
end

Dado('el médico con matrícula {string} tiene un turno asignado el {string} {string}') do |matricula, fecha, hora|
  @matricula = matricula
  @repo_medicos = RepositorioMedicos.new(@logger)
  @repo_turnos = RepositorioTurnos.new(@logger)
  @repo_paciente = RepositorioPacientes.new(@logger)

  medico = @repo_medicos.find_by_matricula(matricula)
  paciente = @repo_paciente.find_by_dni(@dni_registrado)

  fecha = Date.parse(fecha)
  hora = Hora.new(*hora.split(':').map(&:to_i))
  horario = Horario.new(fecha, hora)

  turno = medico.asignar_turno(horario, paciente)
  @repo_turnos.save(turno)
end

Entonces('no se muestran turnos disponibles en la respuesta correcta') do
  @response = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  @parsed_response = JSON.parse(@response.body)

  expect(@response.status).to eq 200
  expect(@parsed_response[:turnos]).to be nil
end

Entonces('no se muestran turnos disponibles en la respuesta erronea') do
  @response = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  @parsed_response = JSON.parse(@response.body)

  expect(@response.status).to be_between(400, 499).inclusive
  expect(@parsed_response[:turnos]).to be nil
end

Dado('que hoy es {string}') do |fecha|
  @fecha_de_hoy = Date.parse(fecha)
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

def cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)
  minutos_totales_de_jornada = (hora_fin_jornada.hora - hora_inicio_jornada.hora) * 60
  minutos_totales_de_jornada += hora_fin_jornada.minutos - hora_inicio_jornada.minutos
  minutos_totales_de_jornada / duracion_turno
end

def llenar_turnos_de_un_dia(matricula_medico, fecha_a_llenar, duracion_turno, turnero)
  dni = "100_#{fecha_a_llenar}_"
  hora_inicio_jornada = Hora.new(8, 0)
  hora_fin_jornada = Hora.new(18, 0)
  cantidad_turnos = cantidad_turnos_en_un_dia(hora_inicio_jornada, hora_fin_jornada, duracion_turno)

  hora_a_asignar = hora_inicio_jornada

  cantidad_turnos.times do |i|
    nuevo_dni = "#{dni}+#{i}"
    hora_a_asignar += Hora.new(0, duracion_turno) if i != 0

    turnero.crear_paciente("j+#{i}@perez.com", nuevo_dni, "juanperez+#{i}")
    turnero.asignar_turno(matricula_medico,
                          fecha_a_llenar.to_s,
                          "#{hora_a_asignar.hora}:#{hora_a_asignar.minutos}",
                          nuevo_dni)
  end
end

Dado('el médico con matrícula {string} no tiene turnos disponibles en los próximos {int} días') do |matricula, dias|
  convertidor_de_tiempo = ConvertidorDeTiempo.new('%Y-%m-%d', ':', '%-H:%M')

  turnero = Turnero.new(RepositorioPacientes.new(@logger),
                        RepositorioEspecialidades.new(@logger),
                        RepositorioMedicos.new(@logger),
                        RepositorioTurnos.new(@logger),
                        ProveedorDeFeriados.new(@api_feriado_url),
                        ProveedorDeFecha.new,
                        ProveedorDeHora.new,
                        convertidor_de_tiempo)
  fecha_de_maniana = @fecha_de_hoy + 1
  dias.to_i.times do |i|
    llenar_turnos_de_un_dia(matricula, fecha_de_maniana + i, @duracion_turno, turnero)
  end

  turnos = turnero.obtener_turnos_disponibles(matricula)
  expect(turnos).to eq([])
end

Entonces('recibo mensaje de error {string}') do |error_msg|
  parsed_response = JSON.parse(@response.body)
  expect(parsed_response['mensaje_error']).to eq(error_msg)
end
