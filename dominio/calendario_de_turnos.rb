require_relative '../lib/horario'

class CalendarioDeTurnos
  def initialize(proveedor_de_fecha, proveedor_de_hora)
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
  end

  def fecha_actual
    @proveedor_de_fecha.hoy
  end

  def hora_actual
    @proveedor_de_hora.hora_actual
  end
end
