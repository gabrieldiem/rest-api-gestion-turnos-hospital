require 'active_model'
require_relative '../dominio/turnero'
require_relative '../dominio/turno'
require_relative '../dominio/exceptions/turno_no_disponible_exception'
require_relative '../dominio/exceptions/horario_superpuesto_exception'
require_relative '../dominio/calendario_de_turnos'

class Medico
  include ActiveModel::Validations
  attr_reader :nombre, :apellido, :matricula, :especialidad
  attr_accessor :id, :created_on, :updated_on, :turnos_asignados

  validates :especialidad, presence: { message: 'Para crear un médico se requiere una especialidad existente' }

  def initialize(nombre, apellido, matricula, especialidad, id = nil)
    @nombre = nombre
    @apellido = apellido
    @matricula = matricula
    @especialidad = especialidad
    @turnos_asignados = []
    @id = id
    validate!
  end

  def asignar_turno(horario, paciente)
    tiene_paciente_disponibilidad = paciente.tiene_disponibilidad?(horario, Hora.new(0, especialidad.duracion))
    raise HorarioSuperpuestoException unless tiene_paciente_disponibilidad

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
