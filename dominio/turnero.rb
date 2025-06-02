class Turnero
  def initialize(repositorio_pacientes, repositorio_especialidades, repositorio_medicos)
    @repositorio_pacientes = repositorio_pacientes
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
  end

  def crear_usuario(email, dni, username)
    usuario = Paciente.new(email, dni, username)
    if paciente_ya_existente?(dni)
      @repositorio_pacientes.save(usuario)
      usuario
    else
      usuario.errors.add(:dni, 'El DNI ya está registrado')
      raise ActiveModel::ValidationError, usuario
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

  def usuarios
    @repositorio_pacientes.all
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
