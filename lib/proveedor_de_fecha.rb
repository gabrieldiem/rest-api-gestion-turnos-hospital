require 'date'

class ProveedorDeFecha
  def initialize(proveedor = Date)
    @proveedor = proveedor
    @fecha_actual = nil
  end

  def hoy
    @fecha_actual ? @fecha_actual : @proveedor.today
  end

end
