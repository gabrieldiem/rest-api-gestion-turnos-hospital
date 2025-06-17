Cuando('cambio la fecha actual a {string} y la hora {string}') do |fecha, hora|
  @hoy = fecha

  body = {
    fecha:,
    hora:
  }.to_json

  @response = Faraday.post('/definir_fecha', body, { 'Content-Type' => 'application/json' })
end

Cuando('pido los turnos disponibles del medico') do
  medico = @medicos.first
  @response = Faraday.get("/medicos/#{medico[:id]}/turnos-disponibles")
  expect(@response.status).to eq 200
  @turnos_disponibles = JSON.parse(@response.body, symbolize_names: true)[:turnos]
end

Entonces('me muestra los valores del dia {string}') do |fecha|
  expect(@turnos_disponibles).to all(include(fecha:))
end
