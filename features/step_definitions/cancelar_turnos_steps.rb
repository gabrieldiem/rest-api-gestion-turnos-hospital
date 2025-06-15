Dado('que existe un paciente registrado con DNI {string} y username {string}') do |dni, username|
  @username = username
  @response = crear_paciente(username, dni, 'juan.salchicon@example.com')
  expect(@response.status).to eq(201)
end

def obtener_paciente_por_username(username)
  response = Faraday.get("/pacientes?username=#{username}")
  expect(response.status).to eq(200)
  JSON.parse(response.body, symbolize_names: true)
end

Dado('que el paciente con DNI {string} saca un turno con el medico de matrícula {string} para el día {string} a las {string}') do |dni, matricula, fecha, hora|
  body = {
    dni:,
    turno: {
      fecha:,
      hora:
    }
  }

  response = Faraday.post("/medicos/#{matricula}/turnos-reservados", body.to_json, { 'Content-Type' => 'application/json' })
  puts "Response body: #{response.body}"
  @turno_reservado = JSON.parse(response.body, symbolize_names: true)
  expect(response.status).to eq(201)
end

Dado('tengo una reputacion de {string}') do |reputacion_esperada|
  paciente = obtener_paciente_por_username(@username)
  expect(paciente[:reputacion]).to eq(reputacion_esperada.to_i)
end

Cuando('cancela a la reserva {string} dias previo a la fecha del turno') do |cant_dias_previos|
  fecha_actual = Date.parse(@turno_reservado[:turno][:fecha])

  @fecha_de_hoy = fecha_actual - cant_dias_previos.to_i

  allow(Date).to receive(:today).and_return(@fecha_de_hoy)

  @response = Faraday.put("/turnos/cancelar/#{@turno_reservado[:id]}")

  puts "Response body: #{@response.body}"
end

Entonces('el turno se cancela exitosamente y mi reputacion se mantiene igual') do
  expect(@response.status).to eq(200)
  paciente = obtener_paciente_por_username(@username)
  expect(paciente['reputacion']).to eq(@reputacion)
end

Cuando('doy cancelar a la reserva {string} horas antes de la fecha del turno') do |cantidad_horas_antes|
  fecha_actual = Date.parse(@turno_reservado[:fecha])

  @fecha_de_hoy = fecha_actual - cantidad_horas_antes.to_i

  allow(Date).to receive(:today).and_return(@fecha_de_hoy)

  @response = Faraday.put("/turnos/cancelar/#{@turno_reservado['id']}")
end

Entonces('el turno se cancela exitosamente y mi reputacion empeora') do
  expect(@response.status).to eq(200)
  paciente = obtener_paciente_por_username(@username)
  expect(paciente['reputacion']).to be < @reputacion
end

Entonces('el turno se libera y puede ser reservado nuevamente') do
  response = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  turnos = JSON.parse(response.body, symbolize_names: true)
  turnos_disponibles = turnos[:turnos]

  expect(turnos_disponibles).to include({
                                          fecha: @turno_reservado[:fecha],
                                          hora: @turno_reservado[:hora]
                                        })
end

Entonces('el turno se pierde y no puede ser reservado nuevamente') do
  response = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  turnos = JSON.parse(response.body, symbolize_names: true)
  turnos_disponibles = turnos[:turnos]

  expect(turnos_disponibles).not_to include({
                                              fecha: @turno_reservado[:fecha],
                                              hora: @turno_reservado[:hora]
                                            })
end
