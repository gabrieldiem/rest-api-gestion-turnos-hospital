Dado('que completo el nombre con {string}') do |nombre_especialidad|
  @request_body = {
    nombre: nombre_especialidad
  }
end

Dado('que completo la duración de turnos con {string} minutos') do |duracion_de_turno|
  @request_body['duracion'] = duracion_de_turno
end

Dado('que completo la recurrencia máxima con {string}') do |recurrencia_maxima|
  @request_body['recurrencia_maxima'] = recurrencia_maxima
end

Dado('que completo el código con {string}') do |codigo|
  @request_body['codigo'] = codigo
end

Cuando('doy de alta la especialidad') do
  request_body_json = @request_body.to_json
  @response = Faraday.post('/especialidades', request_body_json, { 'Content-Type' => 'application/json' })
end

Entonces('la especialidad se crea exitosamente') do
  parsed_response = JSON.parse(@response.body)

  expect(@response.status).to eq 201
  expect(parsed_response['codigo']).to eq @request_body['codigo']
end
