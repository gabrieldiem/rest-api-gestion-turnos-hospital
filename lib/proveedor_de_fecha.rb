require 'date'

class ProveedorDeFecha
  def initialize(proveedor = Date)
    @proveedor = proveedor
    @fecha_actual = nil
  end

  def hoy
    @fecha_actual ? @fecha_actual : @proveedor.today
  end

  def actualizar_fecha_actual(fecha)
    @fecha_actual = Date.parse(fecha)
  end
end
