require_relative '../lib/horario'

class CalendarioDeTurnos
  def initialize(proveedor_de_fecha, proveedor_de_hora, hora_de_comienzo_de_jornada)
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @hora_de_comienzo_de_jornada = hora_de_comienzo_de_jornada
  end

  def fecha_actual
    @proveedor_de_fecha.hoy
  end

  def hora_actual
    @proveedor_de_hora.hora_actual
  end

  def calcular_siguiente_horario(fecha, _cantidad_turnos_explorados, _duracion_de_turno)
    Horario.new(fecha, Hora.new(@hora_de_comienzo_de_jornada.hora, 0))
  end
end
