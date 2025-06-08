require 'date'
require_relative './exceptions/fecha_invalida_exception'

class ConvertidorDeTiempo
  def initialize(formato_fecha, formato_hora_input, formato_hora_output)
    @formato_fecha = formato_fecha
    @formato_hora_input = formato_hora_input
    @formato_hora_output = formato_hora_output
  end

  def estandarizar_fecha(fecha_string)
    Date.strptime(fecha_string, @formato_fecha)
  rescue ArgumentError
    raise FechaInvalidaException
  end

  def estandarizar_hora(fecha_string, hora_string)
    Time.strptime("#{fecha_string} #{hora_string}", "#{@formato_fecha} #{@formato_hora_input}")
  rescue ArgumentError
    raise HoraInvalidaException
  end

  def presentar_hora(hora)
    hora.strftime(@formato_hora_output)
  end
end
