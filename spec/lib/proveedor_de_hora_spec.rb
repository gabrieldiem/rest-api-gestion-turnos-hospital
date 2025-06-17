require 'integration_helper'
require_relative '../../lib/proveedor_de_hora'

describe ProveedorDeHora do
  it 'La hora actual es 10:31' do
    hora_actual = DateTime.new(2025, 1, 1, 10, 31)
    double_proveedor = class_double(Time, now: hora_actual)

    hora_proveida = described_class.new(double_proveedor).hora_actual

    expect(hora_proveida.is_a?(Hora)).to be true
    expect(hora_proveida).to have_attributes(hora: 10, minutos: 31)
  end

  it 'Actualiza la hora actual' do
    hora = DateTime.new(2025, 1, 1, 10, 31)
    double_proveedor = class_double(Time, now: hora)


    proveedor_de_hora = described_class.new(double_proveedor)

    expect(proveedor_de_hora.hora_actual).to have_attributes(hora: 10, minutos: 31)

    nueva_hora = '2025-01-01 05:00:00'

    proveedor_de_hora.actualizar_hora_actual(nueva_hora)

    expect(proveedor_de_hora.hora_actual).to have_attributes(hora: 5, minutos: 00)
  end
end
