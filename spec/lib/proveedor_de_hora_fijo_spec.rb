require 'spec_helper'
require 'time'
require_relative '../../lib/hora'
require_relative '../../lib/proveedor_de_hora_fijo'

RSpec.describe ProveedorDeHoraFijo do
  it 'devuelve la hora fija pasada como objeto Hora' do
    hora = Hora.new(10, 31)
    proveedor = ProveedorDeHoraFijo.new(hora)
    resultado = proveedor.hora_actual
    expect(resultado).to have_attributes(hora: 10, minutos: 31)
  end

  it 'devuelve la hora correctamente si se pasa como string' do
    proveedor = ProveedorDeHoraFijo.new('08:15')
    resultado = proveedor.hora_actual
    expect(resultado).to have_attributes(hora: 8, minutos: 15)
  end

  it 'devuelve la hora correctamente si se pasa como Time' do
    proveedor = ProveedorDeHoraFijo.new(Time.new(2022, 1, 1, 22, 45))
    resultado = proveedor.hora_actual
    expect(resultado).to have_attributes(hora: 22, minutos: 45)
  end
end
