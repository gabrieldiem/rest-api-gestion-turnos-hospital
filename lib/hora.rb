class Hora
  attr_reader :hora, :minutos

  def initialize(hora, minutos)
    extra_horas, normalizados_minutos = minutos.divmod(60)
    @hora = (hora + extra_horas) % 24
    @minutos = normalizados_minutos
  end

  def ==(other)
    other.is_a?(Hora) && hora == other.hora && minutos == other.minutos
  end

  def +(other)
    total_minutos = minutos + other.minutos
    horas_extra_del_total_de_minutos, minutos_restantes = total_minutos.divmod(60)
    total_horas = (hora + other.hora + horas_extra_del_total_de_minutos) % 24
    Hora.new(total_horas, minutos_restantes)
  end
end
