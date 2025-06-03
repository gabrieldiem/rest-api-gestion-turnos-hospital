require_relative '../dominio/turno'

class Medico
  attr_reader :nombre, :apellido, :matricula, :especialidad, :turnos_asignados
  attr_accessor :id, :created_on, :updated_on

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
    @turnos_asignados = []
    @id = id
  end

  def asignar_turno(horario, paciente)
    @turnos_asignados.push(Turno.new(paciente, self, horario))
  end
end
