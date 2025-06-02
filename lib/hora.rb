class Hora
  attr_reader :hora, :minutos

  def initialize(hora, minutos)
    @hora = hora
    @minutos = minutos
  end

  def ==(other)
    other.is_a?(Hora) && hora == other.hora && minutos == other.minutos
  end
end
