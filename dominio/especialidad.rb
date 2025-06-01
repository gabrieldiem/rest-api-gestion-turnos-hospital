class Especialidad
  attr_reader :nombre, :duracion, :recurrencia_maxima, :codigo
  attr_accessor :id, :created_on, :updated_on

  def initialize(nombre, duracion, recurrencia_maxima, codigo, id = nil)
    @nombre = nombre
    @duracion = duracion
    @recurrencia_maxima = recurrencia_maxima
    @codigo = codigo
    @id = id
  end
end
