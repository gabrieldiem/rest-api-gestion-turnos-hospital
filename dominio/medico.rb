class Medico
  attr_reader :nombre, :apellido, :matricula, :especialidad
  attr_accessor :id, :created_on, :updated_on

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
    @id = id
  end
end
