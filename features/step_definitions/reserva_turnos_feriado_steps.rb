Dado('que el día {string} es feriado') do |fecha|
  @fechas_feriado = [Date.parse(fecha)]
  cuando_pido_los_feriados(@fechas_feriado.first.year, @fechas_feriado)
end

Dado('que el día {string} también es feriado') do |fecha|
  feriado_index = @fechas_feriado.size
  @fechas_feriado.push Date.parse(fecha)
  cuando_pido_los_feriados(@fechas_feriado[feriado_index].year, @fechas_feriado)
end

Dado('que el médico con matrícula {string} no tiene turnos reservados el {string}') do |_matricula, _fecha|
  # Nada que hacer
end

Cuando('consulto los turnos disponibles para el médico con matrícula {string}') do |matricula|
  response = Faraday.get("/medicos/#{matricula}/turnos-disponibles")
  @parsed_response = JSON.parse(response.body)
end

Entonces('recibo el mensaje de error {string}') do |error_msg|
  @parsed_response = JSON.parse(@response.body)
  expect(@parsed_response['mensaje_error']).to eq(error_msg)
end

Dado('que hoy es {string} y no es feriado') do |fecha|
  @fecha_de_hoy = Date.parse(fecha)
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end

Dado('que hoy es {string} y es feriado') do |fecha|
  @fecha_de_hoy = Date.parse(fecha)
  allow(Date).to receive(:today).and_return(@fecha_de_hoy)
end
