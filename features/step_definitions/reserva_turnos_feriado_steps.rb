require 'webmock/cucumber'

def cuando_pido_los_feriados(anio, feriados)
  body = feriados.map do |feriado|
    {
      "motivo": 'Es un feriado',
      "tipo": 'inamovible',
      "info": '',
      "dia": feriado.day,
      "mes": feriado.month,
      "id": 'un-feriado'
    }
  end

  stub_request(:any, "#{ENV['API_FERIADOS_URL']}/#{anio}")
    .to_return(body: body.to_json, status: 200)
end

Before do
  SemanticLogger.default_level = :fatal
  @logger = Configuration.logger

  RepositorioTurnos.new(@logger).delete_all
  RepositorioMedicos.new(@logger).delete_all
  RepositorioPacientes.new(@logger).delete_all
  RepositorioEspecialidades.new(@logger).delete_all
end

Dado('que el día {string} es feriado') do |fecha|
  @fecha_feriado = Date.parse(fecha)
  cuando_pido_los_feriados(@fecha_feriado.year, [@fecha_feriado])
end

Dado('que el médico con matrícula {string} no tiene turnos reservados el {string}') do |_matricula, _fecha|
  # Nada que hacer
end

Cuando('consulto los turnos disponibles para el médico con matrícula {string}') do |matricula|
  response = Faraday.get("/medicos/#{matricula}/turnos-reservados")
  @response_body = JSON.parse(response.body, symbolize_names: true)
end

Entonces('recibo el mensaje de error {string}') do |error_msg|
  expect(@response_body['mensaje_error']).to eq(error_msg)
end
