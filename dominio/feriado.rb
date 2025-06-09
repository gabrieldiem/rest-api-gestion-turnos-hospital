class Feriado
  attr_reader :fecha, :motivo, :tipo

  def initialize(fecha, motivo, tipo)
    @fecha = fecha
    @motivo = motivo
    @tipo = tipo
  end
end
