require_relative './disponibilidad_turnos'

class AsignadorDeTurnos
  REPUTACION_VALIDA = 0.8

  def initialize(repositorio_turnos, proveedor_de_feriados, disponibilidad_turnos)
    @repositorio_turnos = repositorio_turnos
    @proveedor_de_feriados = proveedor_de_feriados
    @disponibilidad_turnos = disponibilidad_turnos
  end

  def asignar_turno(medico, paciente, horario)
    duracion_turno = medico.especialidad.duracion

    raise TurnoFeriadoNoEsReservableException if coincide_con_feriado(horario.fecha)
    raise TurnoInvalidoException, 'No se puede reservar en este slot por superposicion con otro turno' unless @disponibilidad_turnos.es_hora_un_slot_valido(duracion_turno,
                                                                                                                                                            horario.hora)
    raise TurnoNoDisponibleException if chequear_si_tiene_turno_asignado(medico, horario.fecha, horario.hora)

    validar_paciente(paciente, medico)
    turno = medico.asignar_turno(horario, paciente)
    @repositorio_turnos.save(turno)
  end

  private

  def validar_paciente(paciente, medico)
    validar_existencia_paciente(paciente)
    validar_reputacion_paciente(paciente)
    validar_recurrencia_maxima(paciente, medico)
  end

  def validar_reputacion_paciente(paciente)
    raise ReputacionInvalidaException, 'No se puede realizar la reserva de turno debiado a la mala reputacion' if paciente.reputacion < REPUTACION_VALIDA && paciente.tiene_turnos_reservados?
  end

  def validar_existencia_paciente(paciente)
    raise PacienteInexistenteException, 'Para reservar un turno se debe estar registrado' if paciente.nil?
  end

  def validar_recurrencia_maxima(paciente, medico)
    raise RecurrenciaMaximaAlcanzadaException if paciente_tiene_recurrencia_maxima_excedida?(paciente, medico)
  end

  def chequear_si_tiene_turno_asignado(medico, fecha_turno_a_chequear, hora_turno_a_chequear)
    horario_turno = Horario.new(fecha_turno_a_chequear, hora_turno_a_chequear)
    medico.tiene_turno_asignado?(horario_turno)
  end

  def coincide_con_feriado(fecha)
    feriados = @proveedor_de_feriados.obtener_feriados(fecha.year)
    feriados.any? { |feriado| feriado.fecha == fecha }
  end

  def paciente_tiene_recurrencia_maxima_excedida?(paciente, medico)
    paciente.obtener_cantidad_de_turnos_reservados_por_especialidad(medico.especialidad) >= medico.especialidad.recurrencia_maxima
  end
end
