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
end
