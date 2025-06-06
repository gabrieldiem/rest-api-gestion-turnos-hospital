Before do
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger
  RepositorioTurnos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que existe la especialidad {string} con código {string}, duración de turno de {string} minutos y recurrencia máxima de {string} turnos') do |nombre, codigo, duracion, recurrencia|
  request_body_json = {
    nombre:,
    codigo:,
    duracion: duracion.to_i,
    recurrencia_maxima: recurrencia.to_i
  }.to_json
  @response = Faraday.post('/especialidades', request_body_json, { 'Content-Type' => 'application/json' })
end

Cuando('consulto las especialidades dadas de alta') do
  @response = Faraday.get('/especialidades')
  @response_body = JSON.parse(@response.body, symbolize_names: true)
end

Entonces('se obtiene una respuesta exitosa') do
  expect(@response.status).to eq(200)
end

Entonces('se muestran {string} especialidades en total') do |total|
  expect(@response_body[:cantidad_total]).to eq(total.to_i)
end

Entonces('se observa la especialidad {string} con código {string}, duración de turno de {string} minutos y recurrencia máxima de {string} turnos') do |nombre, codigo, duracion, recurrencia_maxima|
  expect(@response_body[:especialidades]).to include(
    match(
      codigo:,
      created_on: be_present,
      duracion: duracion.to_i,
      id: be_present,
      nombre:,
      recurrencia_maxima: recurrencia_maxima.to_i
    )
  )
end

Dado('que no existe ninguna especialiadad dada de alta') do
  # Nada que hacer
end

Entonces('no se observa ninguna especialidad') do
  expect(@response_body[:cantidad_total]).to eq(0)
  expect(@response_body[:especialidades]).to be_empty
end
