class EstadoTurnos
  attr_reader :valor

  def self.crear_estado_reservado
    new('reservado')
  end

  def initialize(valor)
    @valor = valor
  end
end

class EstadoTurnoReservado
  ESTADO_RESERVADO = 'reservado'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_RESERVADO
  end
end
