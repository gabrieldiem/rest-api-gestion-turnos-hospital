Cuando('cambio la fecha actual a {string} y la hora {string}') do |fecha, hora|
  @hoy = fecha

  body = {
    fecha:,
    hora:
  }.to_json

  @response = Faraday.post('/definir_fecha', body, { 'Content-Type' => 'application/json' })
end

Dado('que hay un medico registrado de matricula {string} y una especialidad {string}') do |matricula, especialidad|
  especialidad_body = {
    nombre: 'Cardiologia',
    codigo: especialidad,
    duracion: 30,
    recurrencia_maxima: 1
  }.to_json
  response = Faraday.post('/especialidades', especialidad_body, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq 201

  medico_body = {
    nombre: 'Juan',
    apellido: 'Perez',
    matricula:,
    especialidad:
  }
  response = Faraday.post('/medicos', medico_body.to_json, { 'Content-Type' => 'application/json' })
  expect(response.status).to eq 201
  @matricula = matricula
end

Cuando('pido los turnos disponibles del medico asumiendo qu el año actual es {string}') do |anio_actual|
  cuando_pido_los_feriados(anio_actual.to_i, [])
  @response = Faraday.get("/medicos/#{@matricula}/turnos-disponibles")
  expect(@response.status).to eq 200
  @turnos_disponibles = JSON.parse(@response.body, symbolize_names: true)[:turnos]
end

Entonces('me muestra los valores del dia {string}') do |fecha|
  expect(@turnos_disponibles).to all(include(fecha:))
end
