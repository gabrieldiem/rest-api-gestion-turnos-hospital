require_relative './exceptions/fuera_de_horario_exception'
require_relative './estado_turno_reservado'

class Turno
  attr_reader :paciente, :medico, :horario
  attr_accessor :created_on, :updated_on, :id, :estado

  def initialize(paciente, medico, horario, id = nil)
    raise FueraDeHorarioException if es_fuera_de_horario_de_atencion?(horario)

    @paciente = paciente
    @medico = medico
    @horario = horario
    @id = id
    @estado = EstadoTurnoReservado.new
  end

  def ==(other)
    other.is_a?(Turno) &&
      @paciente == other.paciente &&
      @medico == other.medico &&
      @horario == other.horario
  end

  def cambiar_asistencia(_asistio)
    @estado = EstadoTurnoPresente.new
  end

  private

  def es_fuera_de_horario_de_atencion?(horario)
    return true if horario.hora.hora < Turnero::HORA_DE_COMIENZO_DE_JORNADA.hora
    return true if horario.hora.hora >= Turnero::HORA_DE_FIN_DE_JORNADA.hora && horario.hora.minutos >= Turnero::HORA_DE_FIN_DE_JORNADA.minutos

    false
  end
end
