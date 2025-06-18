require_relative '../lib/horario'

class CalendarioDeTurnos
  CANTIDAD_DE_TURNOS_A_CALCULAR_MAXIMA = 5
  CANTIDAD_MAXIMA_DE_DIAS_A_FUTURO_PARA_TURNO = 40
  HORAS_EN_UN_DIA = 24
  MINUTOS_EN_UNA_HORA = 60
  MINUTOS_EN_UN_DIA = HORAS_EN_UN_DIA * MINUTOS_EN_UNA_HORA
  SABADO = 'Saturday'.freeze
  DOMINGO = 'Sunday'.freeze
  FIN_DE_SEMANA = [SABADO, DOMINGO].freeze

  def initialize(hora_de_comienzo_de_jornada,
                 hora_de_fin_de_jornada,
                 proveedor_de_fecha,
                 proveedor_de_hora,
                 proveedor_de_feriados)
    @cantidad_maxima_de_turnos = CANTIDAD_DE_TURNOS_A_CALCULAR_MAXIMA
    @hora_de_comienzo_de_jornada = hora_de_comienzo_de_jornada
    @hora_de_fin_de_jornada = hora_de_fin_de_jornada
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @proveedor_de_feriados = proveedor_de_feriados
  end

  def calcular_turnos_disponibles_por_medico(medico)
    @fecha_posterior = @proveedor_de_fecha.hoy + 1
    ultimo_dia_para_buscar_horarios = @proveedor_de_fecha.hoy + CANTIDAD_MAXIMA_DE_DIAS_A_FUTURO_PARA_TURNO

    @indice_horario_candidato = 0
    horarios_disponibles_elegidos = []
    duracion_turno = medico.especialidad.duracion
    turnos_ya_asignados = medico.turnos_asignados

    while horarios_disponibles_elegidos.size < @cantidad_maxima_de_turnos && @fecha_posterior < ultimo_dia_para_buscar_horarios
      calcular_horarios_disponibles_para_una_fecha(@fecha_posterior,
                                                   horarios_disponibles_elegidos,
                                                   duracion_turno,
                                                   turnos_ya_asignados)
      @fecha_posterior += 1
      @indice_horario_candidato = 0
    end

    horarios_disponibles_elegidos
  end

  def actualizar_proveedores_de_fecha_hora(proveedor_de_fecha, proveedor_de_hora)
    @proveedor_de_fecha = proveedor_de_fecha unless proveedor_de_fecha.nil?
    @proveedor_de_hora = proveedor_de_hora unless proveedor_de_hora.nil?
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

  private

  def calcular_horarios_disponibles_para_una_fecha(fecha_turno, horarios_disponibles_elegidos, duracion_turno, turnos_ya_asignados)
    while horarios_disponibles_elegidos.size < @cantidad_maxima_de_turnos
      horario = calcular_siguiente_horario_disponible(fecha_turno, duracion_turno, turnos_ya_asignados)

      break if horario.nil?

      horarios_disponibles_elegidos.push horario
      @indice_horario_candidato += 1
    end
  end

  def calcular_siguiente_horario_disponible(fecha_actual, duracion_turno, turnos_ya_asignados)
    horario = calcular_siguiente_horario(fecha_actual, @indice_horario_candidato, duracion_turno)
    feriados = @proveedor_de_feriados.obtener_feriados(horario.fecha.year)

    while horario.hora.hora < @hora_de_fin_de_jornada.hora
      if existe_turno_asignado?(horario, turnos_ya_asignados) || es_dia_feriado?(horario, feriados) || es_fin_de_semana?(horario)
        @indice_horario_candidato += 1 # Saltear indice evaluar el siguiente
      else
        return horario
      end

      horario = calcular_siguiente_horario(fecha_actual, @indice_horario_candidato, duracion_turno)
    end
  end

  def calcular_siguiente_horario(fecha, cantidad_turnos_explorados, duracion_de_turno)
    minutos_explorados = (cantidad_turnos_explorados * duracion_de_turno)
    Horario.new(fecha, Hora.new(@hora_de_comienzo_de_jornada.hora, minutos_explorados))
  end

  def existe_turno_asignado?(horario_a_verificar, turnos_ya_asignados)
    turnos_ya_asignados.any? { |turno| turno.horario == horario_a_verificar }
  end

  def es_dia_feriado?(horario_a_verificar, feriados)
    feriados.any? { |feriado| feriado.fecha == horario_a_verificar.fecha }
  end

  def es_fin_de_semana?(horario_a_verificar)
    return true if FIN_DE_SEMANA.include?(horario_a_verificar.fecha.strftime('%A'))

    false
  end
end
