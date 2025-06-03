require_relative '../dominio/turno'

class Medico
  attr_reader :nombre, :apellido, :matricula, :especialidad
  attr_accessor :id, :created_on, :updated_on, :turnos_asignados

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
    @turnos_asignados = []
    @id = id
  end

  def asignar_turno(horario, paciente)
    turno = Turno.new(paciente, self, horario)
    @turnos_asignados.push(turno)
    turno
  end

  def ==(other)
    other.is_a?(Medico) &&
      @nombre == other.nombre &&
      @apellido == other.apellido &&
      @matricula == other.matricula &&
      @especialidad == other.especialidad
  end
end
