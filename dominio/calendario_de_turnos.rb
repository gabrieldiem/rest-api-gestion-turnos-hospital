require_relative '../lib/horario'

class CalendarioDeTurnos
  MINUTOS_EN_UN_DIA = 60
  SABADO = 'Saturday'.freeze
  DOMINGO = 'Sunday'.freeze
  FIN_DE_SEMANA = [SABADO, DOMINGO].freeze

  def initialize(proveedor_de_fecha, proveedor_de_hora, proveedor_de_feriados, hora_de_comienzo_de_jornada, hora_de_fin_de_jornada)
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @proveedor_de_feriados = proveedor_de_feriados
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

  def calcular_siguiente_horario_disponible(fecha_actual, indice_horario, duracion_turno, turnos_ya_asignados)
    horario = calcular_siguiente_horario(fecha_actual, indice_horario, duracion_turno)
    feriados = @proveedor_de_feriados.obtener_feriados(horario.fecha.year)

    while horario.hora.hora < @hora_de_fin_de_jornada.hora
      return horario if esta_disponible?(horario, turnos_ya_asignados, feriados)

      indice_horario += 1
      horario = calcular_siguiente_horario(fecha_actual, indice_horario, duracion_turno)
    end

    nil
  end

  private

  def esta_disponible?(horario, turnos_ya_asignados, feriados)
    !existe_turno_asignado?(horario, turnos_ya_asignados) &&
      !es_dia_feriado?(horario, feriados) &&
      !es_fin_de_semana?(horario)
  end

  def existe_turno_asignado?(horario_a_verificar, turnos_ya_asignados)
    turnos_ya_asignados.any? { |turno| turno.horario == horario_a_verificar }
  end

  def es_dia_feriado?(horario_a_verificar, feriados)
    feriados.any? { |feriado| feriado.fecha == horario_a_verificar.fecha }
  end

  def es_fin_de_semana?(horario_a_verificar)
    FIN_DE_SEMANA.include?(horario_a_verificar.fecha.strftime('%A'))
  end
end
