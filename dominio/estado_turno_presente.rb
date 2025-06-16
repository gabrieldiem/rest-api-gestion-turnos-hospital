class EstadoTurnoPresente
  ESTADO_PRESENTE = 'presente'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_PRESENTE
  end

  def cambiar_asistencia(asistio)
    return EstadoTurnoAusente.new unless asistio

    self
  end

  def reservado?
    false
  end

  def asistio?
    true
  end
end
