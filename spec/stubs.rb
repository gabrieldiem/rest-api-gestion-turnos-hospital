require_relative './web_mock'

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
