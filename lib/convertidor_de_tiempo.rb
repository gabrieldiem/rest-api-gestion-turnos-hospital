require 'date'
require_relative './exceptions/fecha_invalida_exception'

class ConvertidorDeTiempo
  def initialize(formato_fecha, separador_de_hora, formato_hora_output)
    @formato_fecha = formato_fecha
    @separador_de_hora = separador_de_hora
    @formato_hora_output = formato_hora_output
  end

  def estandarizar_fecha(fecha_string)
    Date.strptime(fecha_string, @formato_fecha)
  rescue ArgumentError
    raise FechaInvalidaException
  end

  def estandarizar_hora(hora_string)
    horas, minutos = hora_string.split(@separador_de_hora)
    raise HoraInvalidaException if horas.nil? || minutos.nil?

    Hora.new(horas.to_i, minutos.to_i)  
  end

  def presentar_hora(hora)
    "#{hora.hora}:#{hora.minutos.to_s.rjust(2, '0')}"
  end

  def presentar_fecha(fecha)
    fecha.strftime(@formato_fecha)
  end
end
