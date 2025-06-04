require_relative '../dominio/turno'
require_relative '../dominio/exceptions/turno_no_disponible_exception'
require_relative '../dominio/calculador_de_turnos_libres'

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
    raise TurnoNoDisponibleException if turno_reservado?(horario)

    paciente.tiene_disponibilidad?(horario)
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

  private

  def turno_reservado?(horario)
    CalculadorDeTurnosLibres.new(Turnero::HORA_DE_COMIENZO_DE_JORNADA,
                                 Turnero::HORA_DE_FIN_DE_JORNADA,
                                 ProveedorDeFecha.new,
                                 ProveedorDeHora.new)
                            .chequear_si_tiene_turno_asignado(self, horario.fecha, horario.hora)
  end
end
