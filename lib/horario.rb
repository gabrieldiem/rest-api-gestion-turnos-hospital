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

  def es_despues_de?(otro_horario)
    otro_horario.is_a?(Horario) && to_datetime > otro_horario.to_datetime
  end

  def es_antes_de?(otro_horario)
    otro_horario.is_a?(Horario) && to_datetime < otro_horario.to_datetime
  end

  def hay_superposicion?(otro_horario, otra_duracion, duracion)
    inicio1 = to_datetime
    fin1 = inicio1 + duracion_en_racional(duracion)

    inicio2 = otro_horario.to_datetime
    fin2 = inicio2 + duracion_en_racional(otra_duracion)

    (inicio1 < fin2) && (inicio2 < fin1)
  end

  def calcular_diferencia_con_otro_horario(otro_horario)
    raise ArgumentError, 'El otro horario debe ser una instancia de Horario' unless otro_horario.is_a?(Horario)

    diferencia_dias = to_datetime - otro_horario.to_datetime
    diferencia_horas = calcular_diferencia_de_horas(diferencia_dias)

    diferencia_horas.abs # Devuelve la diferencia horaria en cantidad de horas
  end

  private

  def calcular_diferencia_de_horas(diferencia_dias)
    # DateTime differences are in days, so multiply by 24 to get hours
    diferencia_dias * 24
  end

  def duracion_en_racional(duracion)
    minutos = duracion.hora * 60 + duracion.minutos
    Rational(minutos, 24 * 60)
  end
end
