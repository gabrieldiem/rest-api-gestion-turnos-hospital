Before do
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger
  @repo_turnos = RepositorioTurnos.new(@logger)

  @repo_turnos.delete_all
  RepositorioMedicos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Cuando('el paciente con DNI {string} tiene {string} turnos asistidos y {string} turnos ausentes y {string} turnos reservado') do |dni, cant_asistidos, cant_ausentes, cant_reservados|
  total_turnos = cant_asistidos.to_i + cant_ausentes.to_i + cant_reservados.to_i

  turnos_disponibles = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")['turnos']

  turno_ids = turnos_disponibles.map do |turno|
    fecha = Date.parse(turno['fecha'])
    hora = Time.parse(turno['hora'])

    body = {
      dni:,
      turno: {
        fecha:,
        hora:
      }
    }
    response = Faraday.post(
      "/medicos/#{@matricula}/turnos-reservados",
      body.to_json,
      { 'Content-Type' => 'application/json' }
    )
    expect(response.status).to eq(201)
    JSON.parse(response.body, symbolize_names: true)[:id]
  end

  # TODO: refactorizar con el endpoint de asistencia de turnos para evitar usar repo de turnos

  cant_asistidos.to_i.times do
    id = turno_ids.shift
    turno = @repo_turnos.find(id)
    turno.asistido = true
    @repo_turnos.save(turno)
  end

  cant_ausentes.to_i.times do
    id = turno_ids.shift
    turno = @repo_turnos.find(id)
    turno.asistido = false
    @repo_turnos.save(turno)
  end
end

Cuando('el paciente con DNI {string} reserva {string} turnos con el médico {string}') do |dni, _cant_reservas, _matricula|
  turnos_disponibles = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")['turnos']

  turnos_disponibles.map do |turno|
    fecha = Date.parse(turno['fecha'])
    hora = Time.parse(turno['hora'])

    body = {
      dni:,
      turno: {
        fecha:,
        hora:
      }
    }
    @response = Faraday.post(
      "/medicos/#{@matricula}/turnos-reservados",
      body.to_json,
      { 'Content-Type' => 'application/json' }
    )
  end
end

Entonces('el sistema permite las reservas') do
  expect(@response.status).to eq(201)
end

Entonces('el sistema bloquea las reservas') do
  expect(@response.status).to eq(400)
  expect(@response.body).to include('No se puede realizar la reserva de turno debiado a la mala reputacion')
end
