class Turno
  attr_reader :paciente, :medico, :horario, :id

  def initialize(paciente, medico, horario, id = nil)
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
end
