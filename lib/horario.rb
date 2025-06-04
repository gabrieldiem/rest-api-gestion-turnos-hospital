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

  def hay_superposicion?(otro_horario, duracion)
    inicio1 = to_datetime
    fin1 = inicio1 + duracion_en_racional(duracion)

    inicio2 = otro_horario.to_datetime
    fin2 = inicio2 + duracion_en_racional(duracion)

    (inicio1 < fin2) && (inicio2 < fin1)
  end

  private

  def duracion_en_racional(duracion)
    minutos = duracion.hora * 60 + duracion.minutos
    Rational(minutos, 24 * 60)
  end
end
