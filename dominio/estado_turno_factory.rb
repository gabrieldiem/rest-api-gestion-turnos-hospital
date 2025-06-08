require_relative './estado_turno_reservado'
require_relative './estado_turno_presente'

class EstadoTurnoFactory
  def self.crear_estado(tipo)
    case tipo
    when '0'
      EstadoTurnoReservado.new
    when '1'
      EstadoTurnoPresente.new
    end
  end

  def self.obtener_tipo(_estado)
    '0'
  end

  def self.crear_estado_por_descripcion(descripcion)
    case descripcion
    when 'reservado'
      EstadoTurnoReservado.new
    end
  end
end
