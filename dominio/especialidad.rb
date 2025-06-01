class Especialidad
  attr_reader :nombre, :duracion, :recurrencia_maxima, :codigo, :updated_on, :created_on
  attr_accessor :id

  def initialize(nombre, duracion, recurrencia_maxima, codigo, id = nil)
    @nombre = nombre
    @duracion = duracion
    @recurrencia_maxima = recurrencia_maxima
    @codigo = codigo
    @id = id
  end
end
