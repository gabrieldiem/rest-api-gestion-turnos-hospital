class EstadoTurnoReservado
  ESTADO_RESERVADO = 'reservado'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_RESERVADO
  end
end
