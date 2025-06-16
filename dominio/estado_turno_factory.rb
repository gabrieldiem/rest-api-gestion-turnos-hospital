require_relative './estado_turno_reservado'
require_relative './estado_turno_presente'
require_relative './estado_turno_ausente'

class EstadoTurnoFactory
  ESTADO_RESERVADO = '0'.freeze
  ESTADO_PRESENTE = '1'.freeze
  ESTADO_AUSENTE = '2'.freeze

  ESTADOS_DISPONIBLES = {
    ESTADO_RESERVADO => EstadoTurnoReservado,
    ESTADO_PRESENTE => EstadoTurnoPresente,
    ESTADO_AUSENTE => EstadoTurnoAusente
  }.freeze

  def self.crear_estado(tipo)
    ESTADOS_DISPONIBLES[tipo].new
  end

  def self.obtener_tipo(estado)
    ESTADOS_DISPONIBLES.key(estado.class)
  end
end
