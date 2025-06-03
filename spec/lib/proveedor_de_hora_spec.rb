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
end
