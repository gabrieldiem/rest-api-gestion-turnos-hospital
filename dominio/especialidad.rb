class Especialidad
  attr_accessor :nombre, :duracion, :recurrencia_maxima, :codigo

  def initialize(nombre, duracion, recurrencia_maxima, codigo)
    @nombre = nombre
    @duracion = duracion
    @recurrencia_maxima = recurrencia_maxima
    @codigo = codigo
  end
end
