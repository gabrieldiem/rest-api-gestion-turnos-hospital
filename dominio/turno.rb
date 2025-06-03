class Turno
  attr_reader :paciente, :medico, :horario, :id

  def initialize(paciente, medico, horario, id = nil)
    @paciente = paciente
    @medico = medico
    @horario = horario
    @id = id
  end
end
