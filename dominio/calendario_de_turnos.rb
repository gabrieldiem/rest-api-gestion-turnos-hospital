require_relative '../lib/horario'

class CalendarioDeTurnos
  MINUTOS_EN_UN_DIA = 60

  def initialize(proveedor_de_fecha, proveedor_de_hora, hora_de_comienzo_de_jornada, hora_de_fin_de_jornada)
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @hora_de_comienzo_de_jornada = hora_de_comienzo_de_jornada
    @hora_de_fin_de_jornada = hora_de_fin_de_jornada
  end

  def fecha_actual
    @proveedor_de_fecha.hoy
  end

  def hora_actual
    @proveedor_de_hora.hora_actual
  end

  def es_hora_un_slot_valido(duracion_turno, hora_turno)
    indice_horario_candidato = 0
    while indice_horario_candidato * duracion_turno < MINUTOS_EN_UN_DIA
      siguiente_horario = calcular_siguiente_horario(@proveedor_de_fecha.hoy,
                                                     indice_horario_candidato,
                                                     duracion_turno)
      indice_horario_candidato += 1
      return true if siguiente_horario.hora == hora_turno
    end

    false
  end

  def calcular_siguiente_horario(fecha, cantidad_turnos_explorados, duracion_de_turno)
    minutos_explorados = (cantidad_turnos_explorados * duracion_de_turno)
    Horario.new(fecha, Hora.new(@hora_de_comienzo_de_jornada.hora, minutos_explorados))
  end

  def calcular_siguiente_horario_disponible(fecha_actual, _indice_horario_candidato, duracion_turno, _turnos_asignados)
    horario = calcular_siguiente_horario(fecha_actual, 0, duracion_turno)
    return nil if horario.hora.hora >= @hora_de_fin_de_jornada.hora

    horario
  end
end
