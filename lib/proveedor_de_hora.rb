require 'time'
require_relative './hora'

class ProveedorDeHora
  def initialize(proveedor = Time)
    @proveedor = proveedor
  end

  def hora_actual
    hora_actual = @hora_fija || @proveedor.now
    Hora.new(hora_actual.hour, hora_actual.min)
  end

  def actualizar_hora_actual(hora)
    @hora_fija = Time.parse(hora)
  end
end
