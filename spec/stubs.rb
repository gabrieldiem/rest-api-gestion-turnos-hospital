module FeriadosStubs
  require 'ostruct'

  def cuando_pido_los_feriados(anio, feriados)
    body = []
    feriados.each do |feriado|
      feriado = {
        motivo: 'Es un feriado',
        tipo: 'inamovible',
        info: '',
        dia: feriado.day,
        mes: feriado.month,
        id: 'un-feriado'
      }
      body.push(feriado)
    end

    response = OpenStruct.new(status: 200, body: body.to_json)

    permitir_todas_las_requests_con_parametros_originales
    allow(Faraday).to receive(:get)
      .with("#{ENV['API_FERIADOS_URL']}/#{anio}")
      .and_return(response)
  end

  def cuando_pido_los_feriados_y_hay_error_en_la_api(anio)
    response = OpenStruct.new(status: 500, body: nil)

    permitir_todas_las_requests_con_parametros_originales
    allow(Faraday).to receive(:get)
      .with("#{ENV['API_FERIADOS_URL']}/#{anio}")
      .and_return(response)
  end

  def cuando_pido_los_feriados_y_hay_timeout(anio)
    permitir_todas_las_requests_con_parametros_originales
    allow(Faraday).to receive(:get)
      .with("#{ENV['API_FERIADOS_URL']}/#{anio}")
      .and_raise(Faraday::TimeoutError)
  end

  private

  def permitir_todas_las_requests_con_parametros_originales
    allow(Faraday).to receive(:get).and_call_original
  end
end
