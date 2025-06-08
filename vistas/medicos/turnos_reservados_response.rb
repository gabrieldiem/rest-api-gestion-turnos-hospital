class TurnosReservadosResponse
  def initialize(turnos, convertidor_de_tiempo)
    @turnos = turnos
    @convertidor_de_tiempo = convertidor_de_tiempo
  end

  def to_json(*_args)
    {
      cantidad_turnos: @turnos.size,
      turnos: @turnos.map do |turno|
        {
          fecha: @convertidor_de_tiempo.presentar_fecha(turno.horario.fecha),
          hora: @convertidor_de_tiempo.presentar_hora(turno.horario.hora),
          paciente: {
            dni: turno.paciente.dni.to_s
          }
        }
      end
    }.to_json
  end
end
