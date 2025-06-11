require_relative './calendario_de_turnos'

class AsignadorDeTurnos
  REPUTACION_VALIDA = 0.8

  def initialize(repositorio_turnos, proveedor_de_feriados, calendario_de_turnos)
    @repositorio_turnos = repositorio_turnos
    @proveedor_de_feriados = proveedor_de_feriados
    @calendario_de_turnos = calendario_de_turnos
  end

  def asignar_turno(medico, paciente, horario)
    duracion_turno = medico.especialidad.duracion

    raise TurnoFeriadoNoEsReservableException if coincide_con_feriado(horario.fecha)
    raise TurnoInvalidoException unless @calculador_de_turnos_libres.es_hora_un_slot_valido(duracion_turno,
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
    raise ReputacionInvalidaException, "El paciente con DNI #{paciente.dni} no tiene reputación suficiente para reservar mas de un turno a la vez" if paciente.reputacion < REPUTACION_VALIDA && paciente.tiene_turnos_reservados?
  end

  def validar_existencia_paciente(paciente)
    raise PacienteInexistenteException, 'Para reservar un turno se debe estar registrado' if paciente.nil?
  end

  def validar_recurrencia_maxima(paciente, medico)
    raise RecurrenciaMaximaAlcanzadaException if paciente_tiene_recurrencia_maxima_excedida?(paciente, medico)
  end

  def chequear_si_tiene_turno_asignado(medico, fecha_turno_a_chequear, hora_turno_a_chequear)
    horario_turno = Horario.new(fecha_turno_a_chequear, hora_turno_a_chequear)
    turnos_ya_asignados = medico.turnos_asignados
    turnos_ya_asignados.each do |turno|
      return true if turno.horario == horario_turno
    end
    false
  end

  def coincide_con_feriado(fecha)
    feriados = @proveedor_de_feriados.obtener_feriados(fecha.year)
    feriados.each do |feriado|
      return true if feriado.fecha == fecha
    end
    false
  end

  def paciente_tiene_recurrencia_maxima_excedida?(paciente, medico)
    paciente.obtener_cantidad_de_turnos_reservados_por_especialidad(medico.especialidad) >= medico.especialidad.recurrencia_maxima
  end
end
