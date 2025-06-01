class Turnero
  def initialize(repositorio_usuarios, repositorio_especialidades, repositorio_medicos)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
  end

  def crear_usuario(email, dni, username)
    usuario = Usuario.new(email, dni, username)
    if paciente_ya_existente?(dni)
      @repositorio_usuarios.save(usuario)
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

  def crear_medico(nombre, apellido, matricula, especialidad)
    especialidad = @repositorio_especialidades.find_by_codigo(especialidad)
    medico = Medico.new(nombre, apellido, matricula, especialidad)
    @repositorio_medicos.save(medico)
    medico
  end

  def usuarios
    @repositorio_usuarios.all
  end

  private

  def paciente_ya_existente?(dni)
    if @repositorio_usuarios.find_by_dni(dni)
      false
    else
      true
    end
  end
end
