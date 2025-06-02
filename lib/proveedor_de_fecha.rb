require 'date'

class ProveedorDeFecha
  def initialize(proveedor = Date)
    @proveedor = proveedor
  end

  def hoy
    @proveedor.today
  end
end
