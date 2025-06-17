require 'integration_helper'
require_relative '../../lib/proveedor_de_fecha'

describe ProveedorDeFecha do
  it 'Hoy es el día 25/10/1995' do
    nuevo_hoy = Date.new(1995, 10, 10)
    double_proveedor = class_double(Date, today: nuevo_hoy)

    expect(described_class.new(double_proveedor).hoy).to eq(nuevo_hoy)
  end

  it 'Hoy es hoy (Groundhog Day)' do
    hoy = Date.today
    double_proveedor = class_double(Date, today: hoy)

    expect(described_class.new(double_proveedor).hoy).to eq(hoy)
  end


  it 'Actualiza la fecha actual' do
    fecha = Date.new(1995, 10, 10)
    double_proveedor = class_double(Date, today: fecha)

    proveedor_de_fecha = described_class.new(double_proveedor)

    expect(proveedor_de_fecha.hoy).to eq(fecha)

    nueva_fecha = "2023-10-25"

    proveedor_de_fecha.actualizar_fecha_actual(nueva_fecha)

    expect(proveedor_de_fecha.hoy).to eq(Date.parse(nueva_fecha))
  end

end
