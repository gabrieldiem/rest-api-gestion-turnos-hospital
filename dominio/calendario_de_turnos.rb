require_relative '../lib/horario'

class CalendarioDeTurnos
  def initialize(proveedor_de_fecha, proveedor_de_hora)
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
  end
end
