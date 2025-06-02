class Turnero
  def initialize(repositorio_pacientes, repositorio_especialidades, repositorio_medicos, proveedor_de_fecha)
    @repositorio_pacientes = repositorio_pacientes
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
    @proveedor_de_fecha = proveedor_de_fecha
    @calculador_de_turnos_libres = CalculadorDeTurnosLibres.new(@repositorio_medicos, @proveedor_de_fecha)
  end

  def crear_paciente(email, dni, username)
    paciente = Paciente.new(email, dni, username)
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
    @repositorio_medicos.find_by_matricula(matricula)
  end

  def obtener_turnos_disponibles(matricula)
    medico = buscar_medico(matricula)
    @calculador_de_turnos_libres.calcular_turnos_disponibles_por_medico(medico)
  end

  private

  def paciente_ya_existente?(dni)
    if @repositorio_pacientes.find_by_dni(dni)
      false
    else
      true
    end
  end
end
