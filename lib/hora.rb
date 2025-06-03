class Hora
  attr_reader :hora, :minutos

  def initialize(hora, minutos)
    @hora = hora
    @minutos = minutos
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
