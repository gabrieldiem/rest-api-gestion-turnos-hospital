require 'date'
require_relative '../lib/hora'
require_relative './calendario_de_turnos'
require_relative './asignador_de_turnos'

class Turnero
  HORA_DE_COMIENZO_DE_JORNADA = Hora.new(8, 0)
  HORA_DE_FIN_DE_JORNADA = Hora.new(18, 0)
  MINIMO_PARA_CANCELAR_ANTICIPADAMENTE = 24

  def initialize(repositorios,
                 proveedor_de_feriados,
                 proveedor_de_fecha,
                 proveedor_de_hora,
                 convertidor_de_tiempo)
    @repositorio_pacientes = repositorios.repositorio_pacientes
    @repositorio_especialidades = repositorios.repositorio_especialidades
    @repositorio_medicos = repositorios.repositorio_medicos
    @repositorio_turnos = repositorios.repositorio_turnos
    @proveedor_de_feriados = proveedor_de_feriados
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @calendario_de_turnos = CalendarioDeTurnos.new(HORA_DE_COMIENZO_DE_JORNADA,
                                                   HORA_DE_FIN_DE_JORNADA,
                                                   @proveedor_de_fecha,
                                                   @proveedor_de_hora,
                                                   @proveedor_de_feriados)
    @convertidor_de_tiempo = convertidor_de_tiempo
    @asignador_de_turnos = AsignadorDeTurnos.new(@repositorio_turnos,
                                                 @proveedor_de_feriados,
                                                 @calendario_de_turnos)
  end

  def crear_paciente(email, dni, username)
    paciente = Paciente.new(email, dni, username, Paciente::REPUTACION_INICIAL)
    if !paciente_ya_existente?(dni)
      @repositorio_pacientes.save(paciente)
    else
      paciente.errors.add(:dni, 'El DNI ya está registrado')
      raise ActiveModel::ValidationError, paciente
    end
  end

  def crear_especialidad(nombre, duracion, recurrencia_maxima, codigo)
    especialidad = Especialidad.new(nombre, duracion, recurrencia_maxima, codigo)
    if !especialidad_ya_existente?(codigo)
      @repositorio_especialidades.save(especialidad)
    else
      raise EspecialidadDuplicadaException
    end
  end

  def crear_medico(nombre, apellido, matricula, codigo_especialidad)
    especialidad = @repositorio_especialidades.find_by_codigo(codigo_especialidad)
    medico = Medico.new(nombre, apellido, matricula, especialidad)
    @repositorio_medicos.save(medico)
  end

  def buscar_medico(matricula)
    medico = @repositorio_medicos.find_by_matricula(matricula)
    raise MedicoInexistenteException, "No existe un médico con la matrícula #{matricula}" if medico.nil?

    medico
  end

  def buscar_turno(id_turno)
    turno = @repositorio_turnos.find_by_id(id_turno)
    raise TurnoInexistenteException, "No existe un turno con el ID #{id_turno}" if turno.nil?

    turno
  end

  def asignar_turno(matricula, fecha, hora, dni)
    medico = buscar_medico(matricula)
    paciente = @repositorio_pacientes.find_by_dni(dni)
    horario = obtener_horario_para_turno(fecha, hora)

    @asignador_de_turnos.asignar_turno(medico, paciente, horario)
  end

  def obtener_turnos_disponibles(matricula)
    medico = buscar_medico(matricula)
    @calendario_de_turnos.calcular_turnos_disponibles_por_medico(medico)
  end

  def cambiar_asistencia_turno(id_turno, dni, asistio)
    turno = @repositorio_turnos.find_by_id(id_turno)
    raise TurnoInexistenteException, "No existe un turno con el ID #{id_turno}" if turno.nil?

    paciente = buscar_paciente_por_dni(dni)
    raise PacienteInvalidoException, "El paciente con DNI #{dni} no está asociado a este turno" unless turno.paciente.dni == dni

    turno.cambiar_asistencia(asistio)
    turno_actualizado = @repositorio_turnos.save(turno)
    paciente.actualizar_turno(turno_actualizado)

    paciente.actualizar_reputacion
    @repositorio_pacientes.save(paciente)
    turno_actualizado.actualizar_paciente(paciente)
    turno_actualizado
  end

  def cancelar_turno(id_turno)
    turno = @repositorio_turnos.find_by_id(id_turno)
    raise TurnoInexistenteException, "No existe un turno con el ID #{id_turno}" if turno.nil?
    raise TurnoInvalidoException, 'No se puede cancelar un turno que ya ha sido actualizado' unless turno.reservado?

    es_cancelado_anticipado?(turno) ? @repositorio_turnos.delete(turno) : cambiar_asistencia_turno(turno.id, turno.paciente.dni, false)
  end

  def buscar_paciente_por_username(username)
    raise PacienteInexistenteException, 'Debe tener un username para poder realizar esta accion' if username.nil? || username.empty?

    paciente = @repositorio_pacientes.find_by_username(username)
    raise PacienteInexistenteException, "No existe un paciente con el username #{username}" if paciente.nil?

    paciente
  end

  def buscar_paciente_por_dni(dni)
    paciente = @repositorio_pacientes.find_by_dni(dni)
    raise PacienteInexistenteException, "No existe un paciente con el DNI #{dni}" if paciente.nil?

    paciente
  end

  def obtener_turnos_reservados_del_paciente_por_dni(dni)
    paciente = buscar_paciente_por_dni(dni)
    turnos_reservados = paciente.obtener_turnos_reservados
    raise SinTurnosException, 'No tenés turnos reservados' if turnos_reservados.empty?

    turnos_reservados
  end

  def obtener_historial_turno_del_paciente_por_dni(dni)
    paciente = buscar_paciente_por_dni(dni)
    historial_turnos = paciente.obtener_historial
    raise SinTurnosException, 'No tenés turnos pasados' if historial_turnos.empty?

    historial_turnos
  end

  def obtener_turnos_reservados_por_medico(matricula)
    medico = buscar_medico(matricula)
    raise SinTurnosException, 'El medico no tiene turnos asignados' if medico.turnos_asignados.empty?

    medico.turnos_asignados
  end

  def obtener_especialidades
    @repositorio_especialidades.all
  end

  def obtener_medicos
    @repositorio_medicos.all
  end

  def borrar_todos_los_datos(habilitado)
    raise AccionProhibidaException unless habilitado

    @repositorio_turnos.delete_all
    @repositorio_medicos.delete_all
    @repositorio_pacientes.delete_all
    @repositorio_especialidades.delete_all
  end

  private

  def obtener_horario_para_turno(fecha, hora)
    Horario.new(@convertidor_de_tiempo.estandarizar_fecha(fecha), @convertidor_de_tiempo.estandarizar_hora(hora))
  end

  def paciente_ya_existente?(dni)
    paciente = @repositorio_pacientes.find_by_dni(dni)
    if paciente.nil?
      false
    else
      true
    end
  end

  def especialidad_ya_existente?(codigo)
    especialidad = @repositorio_especialidades.find_by_codigo(codigo)
    if especialidad.nil?
      false
    else
      true
    end
  end

  def es_cancelado_anticipado?(turno)
    turno_horario = turno.horario
    hoy_horario = Horario.new(@convertidor_de_tiempo.estandarizar_fecha(@proveedor_de_fecha.hoy.to_s), @convertidor_de_tiempo.estandarizar_hora(@proveedor_de_hora.hora_actual.to_s))

    diferencia_hora = turno_horario.calcular_diferencia_con_otro_horario(hoy_horario)
    previo_a_hoy = hoy_horario.es_antes_de?(turno_horario)

    diferencia_hora >= MINIMO_PARA_CANCELAR_ANTICIPADAMENTE && previo_a_hoy
  end
end
