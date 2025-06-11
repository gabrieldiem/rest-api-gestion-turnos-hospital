Before do
  Faraday.post('/reset', {})
end

def filtrar_turnos_reservados(dni)
  @turno_reservados_id = []
  paciente_repo = RepositorioPacientes.new(@logger)
  paciente = paciente_repo.find_by_dni(dni)

  paciente.turnos_reservados.each do |turno|
    @turno_reservados_id << turno.id if turno.reservado?
  end
end

Dado('que mi reputacion esperada es {string}') do |reputac_esperada|
  paciente_repo = RepositorioPacientes.new(@logger)
  paciente = paciente_repo.find_by_dni(@dni)
  @reputacion_actual = paciente.reputacion
  expect(@reputacion_actual).to eq(reputac_esperada.to_f)
end

Cuando('el paciente con DNI {string} asiste {string} turnos') do |dni, cant_asistidos|
  filtrar_turnos_reservados(dni)

  cant_asistidos.to_i.times do |i|
    id_turno = @turno_reservados_id[i]
    cargar_asistencia_turno(id_turno, dni, true)
  end
end

Cuando('el paciente con DNI {string} no asiste {string} turnos') do |dni, cant_ausentes|
  filtrar_turnos_reservados(dni)

  cant_ausentes.to_i.times do |i|
    id_turno = @turno_reservados_id[i]
    cargar_asistencia_turno(id_turno, dni, false)
  end
end

Entonces('el paciente mejora su reputacion') do
  @response = Faraday.get("/pacientes?username=#{@request_body[:username]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be > @reputacion_actual
end

Entonces('el paciente empeora su reputacion') do
  @response = Faraday.get("/pacientes?username=#{@request_body[:username]}")
  expect(@response.status).to eq(200)
  parsed_response = JSON.parse(@response.body, symbolize_names: true)
  expect(parsed_response[:reputacion]).to be < @reputacion_actual
end