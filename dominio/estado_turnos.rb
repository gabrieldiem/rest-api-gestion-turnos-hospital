class EstadoTurnos
  attr_reader :valor

  def self.crear_estado_reservado
    new('reservado')
  end

  def initialize(valor)
    @valor = valor
  end
end
