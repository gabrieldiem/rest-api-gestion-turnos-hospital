require_relative './exceptions/fuera_de_horario_exception'

class Turno
  attr_reader :paciente, :medico, :horario
  attr_accessor :created_on, :updated_on, :id

  def initialize(paciente, medico, horario, id = nil)
    raise FueraDeHorarioException, 'El turno no puede ser asignado despues de las 18:00' if horario_despues_de_18?(horario)

    @paciente = paciente
    @medico = medico
    @horario = horario
    @id = id
  end

  def ==(other)
    other.is_a?(Turno) &&
      @paciente == other.paciente &&
      @medico == other.medico &&
      @horario == other.horario
  end

  def horario_despues_de_18?(horario)
    horario.hora.hora >= Turnero::HORA_DE_FIN_DE_JORNADA.hora && horario.hora.minutos > Turnero::HORA_DE_FIN_DE_JORNADA.minutos
  end
end
