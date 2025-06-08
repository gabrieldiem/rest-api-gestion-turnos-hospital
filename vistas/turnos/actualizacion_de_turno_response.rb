class ActualizacionDeTurnoResponse
  def initialize(turnos, convertidor_de_tiempo)
    @turnos = turnos
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args); end
end
