require 'webmock'

def cuando_pido_los_feriados(anio, feriado_respuesta)
  stub_request(:any, "#{ENV['API_FERIADOS_URL']}/#{anio}")
    .to_return(body: feriado_respuesta.to_json, status: 200)
end
