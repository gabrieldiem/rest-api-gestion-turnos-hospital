require_relative '../lib/horario'

class CalculadorDeTurnosLibres
  CANTIDAD_DE_TURNOS_A_CALCULAR_MAXIMA = 5

  def initialize(hora_de_comienzo_de_jornada,
                 hora_de_fin_de_jornada,
                 proveedor_de_fecha,
                 proveedor_de_hora)
    @cantidad_maxima_de_turnos = CANTIDAD_DE_TURNOS_A_CALCULAR_MAXIMA
    @hora_de_comienzo_de_jornada = hora_de_comienzo_de_jornada
    @hora_de_fin_de_jornada = hora_de_fin_de_jornada
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
  end

  def calcular_turnos_disponibles_por_medico(medico)
    fecha_posterior = @proveedor_de_fecha.hoy + 1
    calcular_horarios_disponibles(fecha_posterior, medico.especialidad.duracion)
  end

  private

  # Funciona solo para turnos dentro del mismo dia por el momento, es decir fecha_turno es mañana
  def calcular_horarios_disponibles(fecha_turno, duracion_turno)
    horarios_disponibles_elegidos = []
    @indice_horario_candidato = 0

    while horarios_disponibles_elegidos.size < @cantidad_maxima_de_turnos
      horario = calcular_siguiente_horario_disponible(fecha_turno, duracion_turno, horarios_disponibles_elegidos)
      horarios_disponibles_elegidos.push horario
      @indice_horario_candidato += 1
    end

    horarios_disponibles_elegidos
  end

  def calcular_siguiente_horario_disponible(fecha_actual, duracion, horarios_disponibles_elegidos)
    horario = calcular_siguiente_horario(fecha_actual, @indice_horario_candidato, duracion)

    while horario.hora.hora <= @hora_de_fin_de_jornada.hora
      if existe_turno_asignado?(horario, horarios_disponibles_elegidos)
        @indice_horario_candidato += 1 # Saltear indice evaluar el siguiente
      else
        break
      end

      horario = calcular_siguiente_horario(fecha_actual, @indice_horario_candidato, duracion)
    end

    horario
  end

  def calcular_siguiente_horario(fecha, cantidad_turnos_explorados, duracion_de_turno)
    minutos_explorados = cantidad_turnos_explorados * duracion_de_turno

    hora_de_siguiente_horario = @hora_de_comienzo_de_jornada.hora + (minutos_explorados / 60)
    minutos_de_siguiente_horario = minutos_explorados % 60

    Horario.new(fecha, Hora.new(hora_de_siguiente_horario, minutos_de_siguiente_horario))
  end

  def existe_turno_asignado?(horario_a_verificar, horarios_disponibles_elegidos)
    return false if horarios_disponibles_elegidos.nil? || horarios_disponibles_elegidos.empty?

    horarios_disponibles_elegidos.each do |horario|
      return true if horario == horario_a_verificar
    end

    false
  end
end
