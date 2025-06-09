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

    allow(Faraday).to receive(:get).and_call_original
    allow(Faraday).to receive(:get)
      .with("#{ENV['API_FERIADOS_URL']}/#{anio}")
      .and_return(response)
  end
end
