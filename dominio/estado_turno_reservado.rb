require_relative 'estado_turno_presente'

class EstadoTurnoReservado
  ESTADO_RESERVADO = 'reservado'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_RESERVADO
  end

  def cambiar_asistencia(_asistio)
    EstadoTurnoPresente.new
  end
end
