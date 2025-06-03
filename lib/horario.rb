class Horario
  attr_reader :fecha, :hora

  def initialize(fecha, hora)
    @fecha = fecha
    @hora = hora
  end

  def to_datetime
    DateTime.new(fecha.year, fecha.month, fecha.day, hora.hora, hora.minutos)
  end

  def ==(other)
    other.is_a?(Horario) && hora == other.hora && fecha == other.fecha
  end
end
