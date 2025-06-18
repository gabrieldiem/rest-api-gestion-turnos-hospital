require 'rspec'
require_relative '../../dominio/calendario_de_turnos'
require_relative '../../lib/horario'
require_relative '../../lib/hora'
require_relative '../stubs'

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

describe CalendarioDeTurnos do
  let(:fecha_de_hoy) { Date.new(2025, 1, 1) }
  let(:api_feriados_url) { ENV['API_FERIADOS_URL'] }
  let(:logger) do
    SemanticLogger.default_level = :fatal
    Configuration.logger
  end
  let(:proveedor_de_fecha) do
    proveedor_double = class_double(Date, today: fecha_de_hoy)
    ProveedorDeFecha.new(proveedor_double)
  end
  let(:proveedor_de_hora) do
    proveedor_double = class_double(Time, now: hora_actual)
    ProveedorDeHora.new(proveedor_double)
  end
  let(:proveedor_de_feriados) do
    ProveedorDeFeriados.new(api_feriados_url, logger)
  end
  let(:calendario) do
    described_class.new(proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados, hora_de_comienzo_de_jornada, hora_de_fin_de_jornada)
  end
  let(:hora_actual) { DateTime.new(2025, 1, 1, 8, 0) }
  let(:hora_de_comienzo_de_jornada) { Hora.new(8, 0) }
  let(:hora_de_fin_de_jornada) { Hora.new(17, 0) }
  let(:turnos_asignados) { [] }

  before(:each) do
    ENV['API_FERIADOS_URL'] = 'http://www.feriados-url.com'
    cuando_pido_los_feriados(2025, [])
  end

  it 'obtengo la fecha y la hora actual el proveedor de fecha' do
    expect(calendario.fecha_actual).to eq(fecha_de_hoy)
    expect(calendario.hora_actual).to eq(Hora.new(8, 0))
  end

  it 'calcula el horario para el índice cero' do
    horario = calendario.calcular_siguiente_horario(fecha_de_hoy, 0, 30)
    expect(horario.fecha).to eq(fecha_de_hoy)
    expect(horario.hora.hora).to eq(8)
    expect(horario.hora.minutos).to eq(0)
  end

  it 'calcula el horario para índices mayores a cero' do
    horario = calendario.calcular_siguiente_horario(fecha_de_hoy, 2, 30)
    expect(horario.fecha).to eq(fecha_de_hoy)
    expect(horario.hora.hora).to eq(9)
    expect(horario.hora.minutos).to eq(0)
  end

  it 'retorna true si la hora coincide con un slot calculable' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(fecha_de_hoy, Hora.new(9, 0))
    )
    expect(calendario.es_hora_un_slot_valido(30, Hora.new(9, 0))).to be true
  end

  it 'retorna false si la hora no coincide con un slot calculable' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(fecha_de_hoy, Hora.new(9, 0))
    )
    expect(calendario.es_hora_un_slot_valido(30, Hora.new(9, 30))).to be false
  end

  it 'retorna el horario cuando está disponible' do
    horario_esperado = Horario.new(fecha_de_hoy, Hora.new(9, 0))
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(horario_esperado)

    resultado = calendario.calcular_siguiente_horario_disponible(fecha_de_hoy, 0, 30, turnos_asignados)
    expect(resultado).to eq(horario_esperado)
  end

  it 'retorna nil cuando no hay horarios disponibles hasta el fin de la jornada' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(fecha_de_hoy, Hora.new(17, 30))
    )

    resultado = calendario.calcular_siguiente_horario_disponible(fecha_de_hoy, 0, 30, turnos_asignados)
    expect(resultado).to be_nil
  end

  it 'salta los horarios ya ocupados' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(fecha_de_hoy, Hora.new(9, 0)), Horario.new(fecha_de_hoy, Hora.new(9, 30))
    )

    resultado = calendario.calcular_siguiente_horario_disponible(fecha_de_hoy, 0, 30, [
                                                                   Turno.new(nil, nil, Horario.new(fecha_de_hoy, Hora.new(9, 0)))
                                                                 ])
    expect(resultado).to eq(Horario.new(fecha_de_hoy, Hora.new(9, 30)))
  end

  it 'salta los horarios en fin de semana' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(Date.new(2025, 6, 21), Hora.new(9, 0)), Horario.new(fecha_de_hoy, Hora.new(9, 0))
    )

    resultado = calendario.calcular_siguiente_horario_disponible(Date.new(2025, 6, 21), 0, 30, turnos_asignados)
    expect(resultado).to eq(Horario.new(fecha_de_hoy, Hora.new(9, 0)))
  end

  it 'salta los horarios en días feriados' do
    allow(calendario).to receive(:calcular_siguiente_horario).and_return(
      Horario.new(Date.new(2025, 6, 20), Hora.new(9, 0)), Horario.new(Date.new(2025, 6, 20), Hora.new(9, 0))
    )

    resultado = calendario.calcular_siguiente_horario_disponible(Date.new(2025, 6, 20), 0, 30, turnos_asignados)
    expect(resultado).to eq(Horario.new(Date.new(2025, 6, 20), Hora.new(9, 0)))
  end
end
