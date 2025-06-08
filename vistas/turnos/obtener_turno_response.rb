class ObtenerTurnoResponse
  def initialize(turno, convertidor_de_tiempo)
    @turno = turno
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args); end
end
