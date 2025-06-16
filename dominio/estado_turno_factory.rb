require_relative './estado_turno_reservado'
require_relative './estado_turno_presente'
require_relative './estado_turno_ausente'

class EstadoTurnoFactory
  def self.crear_estado(tipo)
    case tipo
    when '0'
      EstadoTurnoReservado.new
    when '1'
      EstadoTurnoPresente.new
    when '2'
      EstadoTurnoAusente.new
    end
  end

  def self.obtener_tipo(estado)
    return '0' if estado.is_a?(EstadoTurnoReservado)
    return '1' if estado.is_a?(EstadoTurnoPresente)
    return '2' if estado.is_a?(EstadoTurnoAusente)
  end
end
