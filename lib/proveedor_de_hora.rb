require 'time'
require_relative './hora'

class ProveedorDeHora
  def initialize(proveedor = Time)
    @proveedor = proveedor
  end

  def hora_actual
    hora_actual = @proveedor.now
    Hora.new(hora_actual.hour, hora_actual.min)
  end
end
