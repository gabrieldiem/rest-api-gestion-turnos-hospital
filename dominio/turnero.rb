class Turnero
  def initialize(repositorio_usuarios, repositorio_especialidades)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_especialidades = repositorio_especialidades
  end

  def crear_usuario(email)
    usuario = Usuario.new(email)
    @repositorio_usuarios.save(usuario)
    usuario
  end

  def crear_especialidad(nombre, duracion, recurrencia_maxima, codigo)
    Especialidad.new(nombre, duracion, recurrencia_maxima, codigo)
  end

  def usuarios
    @repositorio_usuarios.all
  end
end
