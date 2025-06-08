class EstadoTurnoPresente
  ESTADO_PRESENTE = 'presente'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_PRESENTE
  end
end
