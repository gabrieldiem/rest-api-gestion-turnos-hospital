Dado('que existe un medico dado de alta con nombre {string}, apellido {string}, matricula {string} y especialidad con codigo {string}') do |nombre, apellido, matricula, especialidad|
  body = {
    nombre:,
    apellido:,
    matricula:,
    especialidad:
  }.to_json
  @response = Faraday.post('/medicos', body, { 'Content-Type' => 'application/json' })
  expect(@response.status).to eq(201)
end

Cuando('consulto los médicos dados de alta') do
  @response = Faraday.get('/medicos')
  @response_body = JSON.parse(@response.body, symbolize_names: true)
  expect(@response.status).to eq(200)
end

Entonces('se muestran {string} médicos en total') do |cantidad_total|
  expect(@response_body[:cantidad_total]).to eq(cantidad_total.to_i)
end

Entonces('se observa el médico con nombre {string}, apellido {string}, matricula {string}, especialista en {string} con codigo de especialidad {string}') do |nombre, apellido, matricula, especialiadad, codigo|
  expect(@response_body[:medicos]).to include(
    match(
      nombre:,
      apellido:,
      matricula:,
      especialidad: {
        especialiadad:,
        codigo:
      }
    )
  )
end

Dado('que no existe ningún médico dado de alta') do
  # Nada que hacer
end

Entonces('no se observa ningún médico') do
  expect(@response_body[:cantidad_total]).to eq(0)
  expect(@response_body[:medicos]).to be_empty
end
