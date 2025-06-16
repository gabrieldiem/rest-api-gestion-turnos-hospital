class EstadoTurnoReservado
  ESTADO_RESERVADO = 'reservado'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_RESERVADO
  end

  def cambiar_asistencia(asistio)
    return EstadoTurnoPresente.new if asistio

    EstadoTurnoAusente.new
  end

  def reservado?
    true
  end

  def asistio?
    false
  end
end
