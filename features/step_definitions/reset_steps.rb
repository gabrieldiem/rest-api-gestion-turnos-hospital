def reset_db
  RepositorioMedicos.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que hay {int} médico y un {int} especialidad') do |cantidad_medicos, cantidad_especialidades|
  reset_db

  @cantidad_medicos = cantidad_medicos
  @cantidad_especialidades = cantidad_especialidades

  @medicos = []

  cantidad_especialidades.times do |i|
    request_body_json = {
      nombre: "Cardiologia-#{i}",
      codigo: "car#{i}",
      duracion: 30,
      recurrencia_maxima: 1
    }.to_json
    response = Faraday.post('/especialidades', request_body_json, { 'Content-Type' => 'application/json' })
    expect(response.status).to eq 201
  end

  cantidad_medicos.times do |i|
    medicos_body = {
      nombre: "Juan-#{i}",
      apellido: 'Perez',
      matricula: "NAC00#{i}",
      especialidad: 'car0'
    }
    response = Faraday.post('/medicos', medicos_body.to_json, { 'Content-Type' => 'application/json' })
    expect(response.status).to eq 201
    @medicos << JSON.parse(response.body, symbolize_names: true)
  end
end

Cuando('reseteo los datos') do
  @response = Faraday.post('/reset')
end

Entonces('la respuesta de reset es exitosa') do
  expect(@response.status).to eq 200
end

Entonces('recibo un error de acción prohibida') do
  expect(@response.status).to eq 403
end

Entonces('no hay más especialidades ni médicos') do
  response = Faraday.get('/especialidades')
  response_body = JSON.parse(response.body, symbolize_names: true)
  expect(response_body[:cantidad_total].to_i).to eq(0)

  response = Faraday.get('/medicos')
  response_body = JSON.parse(response.body, symbolize_names: true)
  expect(response_body[:cantidad_total].to_i).to eq(0)
end

Entonces('no se borraron los datos') do
  response = Faraday.get('/especialidades')
  response_body = JSON.parse(response.body, symbolize_names: true)
  expect(response_body[:cantidad_total].to_i).to eq(@cantidad_medicos.to_i)

  response = Faraday.get('/medicos')
  response_body = JSON.parse(response.body, symbolize_names: true)
  expect(response_body[:cantidad_total].to_i).to eq(@cantidad_especialidades.to_i)
end
