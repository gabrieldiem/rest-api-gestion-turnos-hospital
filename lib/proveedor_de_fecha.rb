require 'date'

class ProveedorDeFecha
  def initialize(proveedor = Date)
    @proveedor = proveedor
  end

  def hoy
    @proveedor.today
  end

  def actualizar_fecha_actual(fecha)
    @proveedor = Date.parse(fecha)
  end
end
