class Horario
  attr_reader :fecha, :hora

  def initialize(fecha, hora)
    @fecha = fecha
    @hora = hora
  end

  def ==(other)
    other.is_a?(Horario) && hora == other.hora && fecha == other.fecha
  end
end
