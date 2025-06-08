require 'date'
require_relative '../lib/hora'

class Turnero
  HORA_DE_COMIENZO_DE_JORNADA = Hora.new(8, 0)
  HORA_DE_FIN_DE_JORNADA = Hora.new(18, 0)

  def initialize(repositorio_pacientes,
                 repositorio_especialidades,
                 repositorio_medicos,
                 repositorio_turnos,
                 proveedor_de_fecha,
                 proveedor_de_hora,
                 convertidor_de_tiempo)
    @repositorio_pacientes = repositorio_pacientes
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
    @repositorio_turnos = repositorio_turnos
    @proveedor_de_fecha = proveedor_de_fecha
    @proveedor_de_hora = proveedor_de_hora
    @calculador_de_turnos_libres = CalculadorDeTurnosLibres.new(HORA_DE_COMIENZO_DE_JORNADA,
                                                                HORA_DE_FIN_DE_JORNADA,
                                                                @proveedor_de_fecha,
                                                                @proveedor_de_hora)
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def crear_paciente(email, dni, username)
    paciente = Paciente.new(email, dni, username, 1)
    if paciente_ya_existente?(dni)
      @repositorio_pacientes.save(paciente)
      paciente
    else
      paciente.errors.add(:dni, 'El DNI ya está registrado')
      raise ActiveModel::ValidationError, paciente
    end
  end

  def crear_especialidad(nombre, duracion, recurrencia_maxima, codigo)
    especialidad = Especialidad.new(nombre, duracion, recurrencia_maxima, codigo)
    @repositorio_especialidades.save(especialidad)
  end

  def crear_medico(nombre, apellido, matricula, codigo_especialidad)
    especialidad = @repositorio_especialidades.find_by_codigo(codigo_especialidad)
    medico = Medico.new(nombre, apellido, matricula, especialidad)
    @repositorio_medicos.save(medico)
    medico
  end

  def buscar_medico(matricula)
    medico = @repositorio_medicos.find_by_matricula(matricula)
    raise MedicoInexistenteException, "No existe un médico con la matrícula #{matricula}" if medico.nil?

    medico
  end

  def asignar_turno(matricula, fecha, hora, dni)
    medico = buscar_medico(matricula)
    paciente = @repositorio_pacientes.find_by_dni(dni)
    raise PacienteInexistenteException, 'Para reservar un turno se debe estar registrado' if paciente.nil?

    fecha = @convertidor_de_tiempo.estandarizar_fecha(fecha)
    hora = @convertidor_de_tiempo.estandarizar_hora(hora)
    horario = Horario.new(fecha, hora)

    raise TurnoNoDisponibleException if @calculador_de_turnos_libres.chequear_si_tiene_turno_asignado(medico, fecha, hora)

    turno = medico.asignar_turno(horario, paciente)
    @repositorio_turnos.save(turno)
  end

  def obtener_turnos_disponibles(matricula)
    medico = buscar_medico(matricula)
    @calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico(medico)
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
    raise SinTurnosException, 'No tenés turnos reservados' if paciente.turnos_reservados.empty?

    paciente.turnos_reservados
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

  def paciente_ya_existente?(dni)
    if @repositorio_pacientes.find_by_dni(dni)
      false
    else
      true
    end
  end
end
