require 'rspec'
require_relative '../../dominio/calendario_de_turnos'
require_relative '../../lib/horario'
require_relative '../../lib/hora'

describe CalendarioDeTurnos do
  let(:fecha_de_hoy) { Date.new(2025, 1, 1) }
  let(:hora_actual) { DateTime.new(2025, 1, 1, 8, 0) }
  let(:hora_de_comienzo_de_jornada) { Hora.new(8, 0) }

  let(:proveedor_de_fecha) do
    proveedor_double = class_double(Date, today: fecha_de_hoy)
    ProveedorDeFecha.new(proveedor_double)
  end
  let(:proveedor_de_hora) do
    proveedor_double = class_double(Time, now: hora_actual)
    ProveedorDeHora.new(proveedor_double)
  end

  let(:calendario) do
    described_class.new(proveedor_de_fecha, proveedor_de_hora, hora_de_comienzo_de_jornada)
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
end
