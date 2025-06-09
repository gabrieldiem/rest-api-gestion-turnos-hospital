class Feriado
  attr_reader :fecha, :motivo, :tipo

  def initialize(fecha, motivo, tipo)
    @fecha = fecha
    @motivo = motivo
    @tipo = tipo
  end

  def ==(other)
    other.is_a?(Feriado) &&
      @fecha == other.fecha &&
      @motivo == other.motivo &&
      @tipo == other.tipo
  end
end
