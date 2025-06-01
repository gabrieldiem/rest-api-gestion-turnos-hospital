class Turnero
  def initialize(repositorio_usuarios, repositorio_especialidades, repositorio_medicos)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_especialidades = repositorio_especialidades
    @repositorio_medicos = repositorio_medicos
  end

  def crear_usuario(email)
    usuario = Usuario.new(email)
    @repositorio_usuarios.save(usuario)
    usuario
  end

  def crear_especialidad(nombre, duracion, recurrencia_maxima, codigo)
    especialidad = Especialidad.new(nombre, duracion, recurrencia_maxima, codigo)
    @repositorio_especialidades.save(especialidad)
    especialidad
  end

  def crear_medico(nombre, apellido, matricula, especialidad)
    medico = Medico.new(nombre, apellido, matricula, especialidad)
    @repositorio_medicos.save(medico)
    medico
  end

  def usuarios
    @repositorio_usuarios.all
  end
end
