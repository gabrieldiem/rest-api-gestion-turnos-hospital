class EstadoTurnoPresente
  ESTADO_PRESENTE = 'presente'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_PRESENTE
  end

  def cambiar_asistencia(_asistio)
    EstadoTurnoAusente.new
  end
end
