Before do
  @repo_turnos = RepositorioTurnos.new(@logger)
end

def cargar_asistencias(dni, cant_asistidos, cant_ausentes)
  cant_asistidos.to_i.times do
    id_turno = @turno_ids.shift
    cargar_asistencia_turno(id_turno, dni, true)
  end

  cant_ausentes.to_i.times do
    id_turno = @turno_ids.shift
    cargar_asistencia_turno(id_turno, dni, false)
  end
end

def cargar_asistencia_turno(id_turno, dni, asistio)
  body = {
    dni_paciente: dni,
    asistio:
  }
  @response = Faraday.put("/turnos/#{id_turno}", body.to_json, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(200)
end

def reservar_turnos(matricula, dni, total_turnos)
  response_turnos = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
  turnos_disponibles = JSON.parse(response_turnos.body)['turnos']

  @turno_ids = []
  total_turnos.times do |i|
    # Refresh available turns every 5 iterations
    if i % 5 == 0 && i > 0
      response_turnos = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
      turnos_disponibles.concat(JSON.parse(response_turnos.body)['turnos'])
    end

    turno = turnos_disponibles[i]
    reservar_turno(turno, dni, matricula)
  end
end

def reservar_turno(turno, dni, matricula)
  body = {
    dni:,
    turno: {
      fecha: turno['fecha'],
      hora: turno['hora']
    }
  }

  response = Faraday.post("/medicos/#{matricula}/turnos-reservados",
                          body.to_json,
                          'Content-Type' => 'application/json')

  expect(response.status).to eq(201)
  @turno_ids << JSON.parse(response.body, symbolize_names: true)[:id]
end

Cuando('el paciente con DNI {string} tiene {string} turnos asistidos y {string} turnos ausentes y {string} turnos reservado') do |dni, cant_asistidos, cant_ausentes, cant_reservados|
  RepositorioTurnos.new(@logger).delete_all

  total_turnos = cant_asistidos.to_i + cant_ausentes.to_i + cant_reservados.to_i
  reservar_turnos(@matricula, dni, total_turnos)

  cargar_asistencias(dni, cant_asistidos, cant_ausentes)
end

Cuando('el paciente con DNI {string} reserva {string} turnos con el médico de matricula {string}') do |dni, cant_reservas, _matricula|
  response_turnos = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  turnos_disponibles = JSON.parse(response_turnos.body)['turnos']

  cant_reservas.to_i.times do |i|
    turno = turnos_disponibles[i]
    fecha = turno['fecha']
    hora = turno['hora']

    body = {
      dni:,
      turno: {
        fecha:,
        hora:
      }
    }

    @response = Faraday.post("/medicos/#{@matricula}/turnos-reservados", body.to_json, {
                               'Content-Type' => 'application/json'
                             })

    # Refresh available turns every 5 iterations
    if (i + 1) % 5 == 0
      response_turnos = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
      turnos_disponibles.concat(JSON.parse(response_turnos.body)['turnos'])
    end
  end
end

Entonces('el sistema permite las reservas') do
  expect(@response.status).to eq(201)
end

Entonces('el sistema bloquea las reservas') do
  expect(@response.status).to eq(400)
  expect(@response.body).to include('No se puede realizar la reserva de turno debiado a la mala reputacion')
end
