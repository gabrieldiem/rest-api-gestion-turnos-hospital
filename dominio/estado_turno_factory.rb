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

  def self.obtener_tipo(estado)
    return '0' if estado.is_a?(EstadoTurnoReservado)
    return '1' if estado.is_a?(EstadoTurnoPresente)
  end

  def self.crear_estado_por_descripcion(descripcion)
    case descripcion
    when 'reservado'
      EstadoTurnoReservado.new
    end
  end
end
