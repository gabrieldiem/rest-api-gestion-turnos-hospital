class Medico
  attr_reader :nombre, :apellido, :matricula, :especialidad

  def initialize(nombre, apellido, matricula, especialidad)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
  end
end
