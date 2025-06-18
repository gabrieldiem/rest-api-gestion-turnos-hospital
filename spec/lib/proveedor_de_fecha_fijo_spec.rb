require 'spec_helper'
require 'date'
require_relative '../../lib/proveedor_de_fecha_fijo'

describe ProveedorDeFechaFijo do
  it 'devuelve la fecha fija pasada en el constructor' do
    fecha = Date.new(2030, 5, 15)
    proveedor = described_class.new(fecha)
    expect(proveedor.hoy).to eq(fecha)
  end

  it 'devuelve la fecha como Date aunque se pase un string' do
    proveedor = described_class.new('2022-12-31')
    expect(proveedor.hoy).to eq(Date.new(2022, 12, 31))
  end

  it 'devuelve la fecha como Date aunque se pase un DateTime' do
    proveedor = described_class.new(DateTime.new(2021, 1, 1, 10, 0, 0))
    expect(proveedor.hoy).to eq(Date.new(2021, 1, 1))
  end
end
