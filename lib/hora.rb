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

  def hay_superposicion?(otra_hora, duracion)
    intervalo1 = construir_intervalo(self, duracion)
    intervalo2 = construir_intervalo(otra_hora, duracion)

    rangos1 = expandir_intervalo(intervalo1)
    rangos2 = expandir_intervalo(intervalo2)

    rangos1.any? do |r1|
      rangos2.any? do |r2|
        se_solapan?(r1, r2)
      end
    end
  end

  protected

  def construir_intervalo(inicio, duracion)
    duracion_min = duracion.hora * 60 + duracion.minutos
    inicio_min = inicio.minutos_totales
    fin_min = (inicio_min + duracion_min) % (24 * 60)
    [inicio_min, fin_min]
  end

  def expandir_intervalo(intervalo)
    inicio, fin = intervalo
    if fin >= inicio
      [[inicio, fin]]
    else
      [[inicio, 24 * 60], [0, fin]]
    end
  end

  def se_solapan?(rango1, rango2)
    a_ini, a_fin = rango1
    b_ini, b_fin = rango2
    a_ini < b_fin && b_ini < a_fin
  end

  def minutos_totales
    hora * 60 + minutos
  end
end
