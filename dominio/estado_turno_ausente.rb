class EstadoTurnoAusente
  ESTADO_AUSENTE = 'ausente'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_AUSENTE
  end

  def cambiar_asistencia(asistio)
    return EstadoTurnoPresente.new if asistio

    self
  end
end
