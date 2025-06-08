require_relative './estado_turnos'

class EstadoTurnoFactory
  def self.crear_estado(tipo)
    case tipo
    when '0'
      EstadoTurnoReservado.new
    else
      raise ArgumentError, "Tipo de estado desconocido: #{tipo}"
    end
  end
end
