class EstadoTurnoAusente
  ESTADO_AUSENTE = 'ausente'.freeze

  attr_reader :descripcion

  def initialize
    @descripcion = ESTADO_AUSENTE
  end
end
